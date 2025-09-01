require "excon"

res = Excon.get("https://example.com")
puts res.body
puts "---"
p res.class # Excon::Response
p res.headers # Excon::Headers
p res.headers["Last-Modified"]
p res.remote_ip
p res.status

__END__
# https://github.com/excon/excon/blob/master/lib/excon.rb
# Generic non-persistent HTTP methods
HTTP_VERBS.each do |method|
  module_eval <<-DEF, __FILE__, __LINE__ + 1
    def #{method}(url, params = {}, &block)
      new(url, params).request(:method => :#{method}, &block)
    end
  DEF
end

Excon::Connection.new -> Excon::Connection#request

# https://github.com/excon/excon/blob/master/lib/excon/connection.rb
def request(params={}, &block)
  # @data has defaults, merge in new params to override
  datum = @data.merge(params)

  # Set the deadline for the current request in order to determine when we have run out of time.
  # Only set when a request timeout has been defined.
  if datum[:timeout]
    datum[:deadline] = Process.clock_gettime(Process::CLOCK_MONOTONIC) + datum[:timeout]
  end

  datum[:headers] = @data[:headers].merge(datum[:headers] || {})

  validate_params(:request, params, datum[:middlewares])
  # If the user passed in new middleware, we want to validate that the original connection parameters
  # are still valid with the provided middleware.
  if params[:middlewares]
    validate_params(:connection, @data, datum[:middlewares])
  end

  if datum[:user] || datum[:password]
    user, pass = Utils.unescape_uri(datum[:user].to_s), Utils.unescape_uri(datum[:password].to_s)
    datum[:headers]['Authorization'] ||= 'Basic ' + ["#{user}:#{pass}"].pack('m').delete(Excon::CR_NL)
  end

  host_key = datum[:headers].keys.detect {|k| k.casecmp?('Host') } || 'Host'
  if datum[:scheme] == UNIX
    datum[:headers][host_key] ||= ''
  else
    datum[:headers][host_key] ||= datum[:host] + port_string(datum)
  end

  # RFC 7230, section 5.4, states that the Host header SHOULD be the first one # to be present.
  # Some web servers will reject the request if it comes too late, so let's hoist it to the top.
  if (host = datum[:headers].delete(host_key))
    datum[:headers] = { host_key => host }.merge(datum[:headers])
  end

  # default to GET if no method specified
  unless datum[:method]
    datum[:method] = :get
  end

  # if path is empty or doesn't start with '/', insert one
  unless datum[:path][0, 1] == '/'
    datum[:path] = datum[:path].dup.insert(0, '/')
  end

  if block_given?
    Excon.display_warning('Excon requests with a block are deprecated, pass :response_block instead.')
    datum[:response_block] = block
  end

  datum[:connection] = self

  # cleanup data left behind on persistent connection after interrupt
  if datum[:persistent] && !@persistent_socket_reusable
    reset
  end

  datum[:stack] = datum[:middlewares].map do |middleware|
    lambda {|stack| middleware.new(stack)}
  end.reverse.inject(self) do |middlewares, middleware|
    middleware.call(middlewares)
  end
  datum = datum[:stack].request_call(datum)

  unless datum[:pipeline]
    @persistent_socket_reusable = false
    datum = response(datum)
    @persistent_socket_reusable = true

    if datum[:persistent]
      if (key = datum[:response][:headers].keys.detect {|k| k.casecmp?('Connection') })
        if datum[:response][:headers][key].casecmp?('close')
          reset
        end
      end
    else
      reset
    end

    Excon::Response.new(datum[:response])
  else
    datum
  end
rescue => error
  reset

  # If we didn't get far enough to initialize datum and the middleware stack, just raise
  raise error if !datum

  datum[:error] = error
  if datum[:stack]
    datum[:stack].error_call(datum)
  else
    raise error
  end
end

def request_call(datum)
  begin
    if datum.has_key?(:response)
      # we already have data from a middleware, so bail
      return datum
    else
      socket(datum).data = datum
      # start with "METHOD /path"
      request = datum[:method].to_s.upcase + ' '
      if datum[:proxy] && datum[:scheme] != HTTPS
        request << datum[:scheme] << '://' << datum[:host] << port_string(datum)
      end
      request << datum[:path]

      # add query to path, if there is one
      request << query_string(datum)

      # finish first line with "HTTP/1.1\r\n"
      request << HTTP_1_1

      if datum.has_key?(:request_block)
        datum[:headers]['Transfer-Encoding'] = 'chunked'
      else
        body = datum[:body].is_a?(String) ? StringIO.new(datum[:body]) : datum[:body]

        # The HTTP spec isn't clear on it, but specifically, GET requests don't usually send bodies;
        # if they don't, sending Content-Length:0 can cause issues.
        unless datum[:method].to_s.casecmp?('GET') && body.nil?
          unless datum[:headers].has_key?('Content-Length')
            datum[:headers]['Content-Length'] = detect_content_length(body)
          end
        end
      end

      # add headers to request
      request << Utils.headers_hash_to_s(datum[:headers])

      # add additional "\r\n" to indicate end of headers
      request << CR_NL

      if datum.has_key?(:request_block)
        socket(datum).write(request) # write out request + headers
        while true # write out body with chunked encoding
          chunk = datum[:request_block].call
          chunk = binary_encode(chunk)
          if chunk.length > 0
            socket(datum).write(chunk.length.to_s(16) << CR_NL << chunk << CR_NL)
          else
            socket(datum).write("0#{CR_NL}#{CR_NL}")
            break
          end
        end
      elsif body.nil?
        socket(datum).write(request) # write out request + headers
      else # write out body
        if body.respond_to?(:binmode) && !body.is_a?(StringIO)
          body.binmode
        end
        if body.respond_to?(:rewind)
          body.rewind  rescue nil
        end

        # if request + headers is less than chunk size, fill with body
        request = binary_encode(request)
        chunk = body.read([datum[:chunk_size] - request.length, 0].max)
        if chunk
          chunk = binary_encode(chunk)
          socket(datum).write(request << chunk)
        else
          socket(datum).write(request) # write out request + headers
        end

        while (chunk = body.read(datum[:chunk_size]))
          socket(datum).write(chunk)
        end
      end
    end
  rescue => error
    case error
    when Excon::Errors::InvalidHeaderKey, Excon::Errors::InvalidHeaderValue, Excon::Errors::StubNotFound, Excon::Errors::Timeout
      raise(error)
    when Errno::EPIPE
      # Read whatever remains in the pipe to aid in debugging
      response = socket.read rescue ""
      error = Excon::Error.new(response + error.message)
      raise_socket_error(error)
    else
      raise_socket_error(error)
    end
  end

  datum
end

def socket(datum = @data)
  unix_proxy = datum[:proxy] ? datum[:proxy][:scheme] == UNIX : false
  sockets[@socket_key] ||= if datum[:scheme] == UNIX || unix_proxy
    Excon::UnixSocket.new(datum)
  elsif datum[:ssl_uri_schemes].include?(datum[:scheme])
    Excon::SSLSocket.new(datum)
  else
    Excon::Socket.new(datum)
  end
end
