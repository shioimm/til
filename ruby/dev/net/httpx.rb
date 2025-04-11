require "httpx"

res = HTTPX.get("https://example.com")
puts res.body
puts("---")
p res
# #<Response:232
#   HTTP/2.0
#   @status=200
#   @headers={
#     "accept-ranges" => ["bytes"],
#     "content-type" => ["text/html"],
#     "etag" => ["\"84238dfc8092e5d9c0dac8ef93371a07:1736799080.121134\""],
#     "last-modified" => ["Mon, 13 Jan 2025 20:11:20 GMT"],
#     "vary" => ["Accept-Encoding"],
#     "content-encoding" => ["gzip"],
#     "cache-control" => ["max-age=412"],
#     "date" => ["Fri, 28 Mar 2025 00:59:46 GMT"],
#     "alt-svc" => ["h3=\":443\"; ma=93600,h3-29=\":443\"; ma=93600,quic=\":443\"; ma=93600; v=\"43\""],
#     "content-length" => ["648"]
#     }
#   @body=1256
# >
p res.status
p res.headers["last-modified"]
__END__
- res, res.headersともに無名クラスのインスタンスになっている

# https://github.com/HoneyryderChuck/httpx/blob/master/lib/httpx/chainable.rb

%w[head get post put delete trace options connect patch].each do |meth|
  class_eval(<<-MOD, __FILE__, __LINE__ + 1)
    def #{meth}(*uri, **options)                # def get(*uri, **options)
      request("#{meth.upcase}", uri, **options) #   request("GET", uri, **options)
    end                                         # end
  MOD
end

def request(*args, **options)
  branch(default_options).request(*args, **options)
end

def branch(options, &blk)
  return self.class.new(options, &blk) if is_a?(S)

  Session.new(options, &blk)
en

# https://github.com/HoneyryderChuck/httpx/blob/master/lib/httpx/session.rb

def request(*args, **params)
  raise ArgumentError, "must perform at least one request" if args.empty?

  requests = args.first.is_a?(Request) ? args : build_requests(*args, params)
  responses = send_requests(*requests)
  return responses.first if responses.size == 1

  responses
end

def send_requests(*requests)
  selector = get_current_selector { Selector.new }
  begin
    _send_requests(requests, selector)
    receive_requests(requests, selector)
  ensure
    unless @wrapped
      if @persistent
        deactivate(selector)
      else
        close(selector)
      end
    end
  end
end

def send_request(request, selector, options = request.options)
  error = begin
    catch(:resolve_error) do
      connection = find_connection(request.uri, selector, options)
      connection.send(request)
    end
  rescue StandardError => e
    e
  end
  return unless error && error.is_a?(Exception)

  raise error unless error.is_a?(Error)

  response = ErrorResponse.new(request, error)
  request.response = response
  request.emit(:response, response)
end

def find_connection(request_uri, selector, options)
  if (connection = selector.find_connection(request_uri, options))
    return connection
  end

  connection = @pool.checkout_connection(request_uri, options)

  case connection.state
  when :idle
    do_init_connection(connection, selector)
  when :open
    if options.io
      select_connection(connection, selector)
    else
      pin_connection(connection, selector)
    end
  when :closing, :closed
    connection.idling
    select_connection(connection, selector)
  else
    pin_connection(connection, selector)
  end

  connection
end
