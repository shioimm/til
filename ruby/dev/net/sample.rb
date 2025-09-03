require "net/http"

uri = URI.parse("https://example.com/")
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = (uri.scheme == "https")

req = Net::HTTP::Get.new("/index.html")
res = http.request(req)
puts res.body
puts("---")

p http.class # Net::HTTP
p res.class # Net::HTTPOK
p res.header # #<Net::HTTPOK 200 OK readbody=true>
res.each_key { p it }
p res["Last-Modified"]

p Net::HTTP.get("example.com", "/index.html", 80) # => String
p Net::HTTP.get(uri) # => String

p Net::HTTP.get_response(uri, { "Accept" => "text/html" }) # => Net::HTTPOK

uri = URI("https://httpbin.org/post")
data = '{ "foo": "bar" }'
p Net::HTTP.post(uri, data, { "Content-Type": "application/json" }) # => #<Net::HTTPOK 200 OK readbody=true>
__END__
# https://github.com/ruby/ruby/blob/master/lib/net/http.rb

def request(req, body = nil, &block)  # :yield: +response+
  unless started?
    start {
      req['connection'] ||= 'close'
      return request(req, body, &block)
    }
  end
  if proxy_user()
    req.proxy_basic_auth proxy_user(), proxy_pass() unless use_ssl?
  end
  req.set_body_internal body
  res = transport_request(req, &block)
  if sspi_auth?(res)
    sspi_auth(req)
    res = transport_request(req, &block)
  end
  res
end

def start  # :yield: http
  raise IOError, 'HTTP session already opened' if @started
  if block_given?
    begin
      do_start
      return yield(self)
    ensure
      do_finish
    end
  end
  do_start
  self
end

def do_start
  connect
  @started = true
end

def connect
  if use_ssl?
    # reference early to load OpenSSL before connecting,
    # as OpenSSL may take time to load.
    @ssl_context = OpenSSL::SSL::SSLContext.new
  end

  if proxy? then
    conn_addr = proxy_address
    conn_port = proxy_port
  else
    conn_addr = conn_address
    conn_port = port
  end

  debug "opening connection to #{conn_addr}:#{conn_port}..."
  s = Timeout.timeout(@open_timeout, Net::OpenTimeout) {
    begin
      TCPSocket.open(conn_addr, conn_port, @local_host, @local_port)
    rescue => e
      raise e, "Failed to open TCP connection to " +
        "#{conn_addr}:#{conn_port} (#{e.message})"
    end
  }
  s.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
  debug "opened"
  if use_ssl?
    if proxy?
      if @proxy_use_ssl
        proxy_sock = OpenSSL::SSL::SSLSocket.new(s)
        ssl_socket_connect(proxy_sock, @open_timeout)
      else
        proxy_sock = s
      end
      proxy_sock = BufferedIO.new(proxy_sock, read_timeout: @read_timeout,
                                  write_timeout: @write_timeout,
                                  continue_timeout: @continue_timeout,
                                  debug_output: @debug_output)
      buf = +"CONNECT #{conn_address}:#{@port} HTTP/#{HTTPVersion}\r\n" \
        "Host: #{@address}:#{@port}\r\n"
      if proxy_user
        credential = ["#{proxy_user}:#{proxy_pass}"].pack('m0')
        buf << "Proxy-Authorization: Basic #{credential}\r\n"
      end
      buf << "\r\n"
      proxy_sock.write(buf)
      HTTPResponse.read_new(proxy_sock).value
      # assuming nothing left in buffers after successful CONNECT response
    end

    ssl_parameters = Hash.new
    iv_list = instance_variables
    SSL_IVNAMES.each_with_index do |ivname, i|
      if iv_list.include?(ivname)
        value = instance_variable_get(ivname)
        unless value.nil?
          ssl_parameters[SSL_ATTRIBUTES[i]] = value
        end
      end
    end
    @ssl_context.set_params(ssl_parameters)
    unless @ssl_context.session_cache_mode.nil? # a dummy method on JRuby
      @ssl_context.session_cache_mode =
          OpenSSL::SSL::SSLContext::SESSION_CACHE_CLIENT |
              OpenSSL::SSL::SSLContext::SESSION_CACHE_NO_INTERNAL_STORE
    end
    if @ssl_context.respond_to?(:session_new_cb) # not implemented under JRuby
      @ssl_context.session_new_cb = proc {|sock, sess| @ssl_session = sess }
    end

    # Still do the post_connection_check below even if connecting
    # to IP address
    verify_hostname = @ssl_context.verify_hostname

    # Server Name Indication (SNI) RFC 3546/6066
    case @address
    when Resolv::IPv4::Regex, Resolv::IPv6::Regex
      # don't set SNI, as IP addresses in SNI is not valid
      # per RFC 6066, section 3.

      # Avoid openssl warning
      @ssl_context.verify_hostname = false
    else
      ssl_host_address = @address
    end

    debug "starting SSL for #{conn_addr}:#{conn_port}..."
    s = OpenSSL::SSL::SSLSocket.new(s, @ssl_context)
    s.sync_close = true
    s.hostname = ssl_host_address if s.respond_to?(:hostname=) && ssl_host_address

    if @ssl_session and
       Process.clock_gettime(Process::CLOCK_REALTIME) < @ssl_session.time.to_f + @ssl_session.timeout
      s.session = @ssl_session
    end
    ssl_socket_connect(s, @open_timeout)
    if (@ssl_context.verify_mode != OpenSSL::SSL::VERIFY_NONE) && verify_hostname
      s.post_connection_check(@address)
    end
    debug "SSL established, protocol: #{s.ssl_version}, cipher: #{s.cipher[0]}"
  end
  @socket = BufferedIO.new(s, read_timeout: @read_timeout,
                           write_timeout: @write_timeout,
                           continue_timeout: @continue_timeout,
                           debug_output: @debug_output)
  @last_communicated = nil
  on_connect
rescue => exception
  if s
    debug "Conn close because of connect error #{exception}"
    s.close
  end
  raise
end

def transport_request(req)
  count = 0
  begin
    begin_transport req
    res = catch(:response) {
      begin
        req.exec @socket, @curr_http_version, edit_path(req.path)
      rescue Errno::EPIPE
        # Failure when writing full request, but we can probably
        # still read the received response.
      end

      begin
        res = HTTPResponse.read_new(@socket)
        res.decode_content = req.decode_content
        res.body_encoding = @response_body_encoding
        res.ignore_eof = @ignore_eof
      end while res.kind_of?(HTTPInformation)

      res.uri = req.uri

      res
    }
    res.reading_body(@socket, req.response_body_permitted?) {
      if block_given?
        count = max_retries # Don't restart in the middle of a download
        yield res
      end
    }
  rescue Net::OpenTimeout
    raise
  rescue Net::ReadTimeout, IOError, EOFError,
         Errno::ECONNRESET, Errno::ECONNABORTED, Errno::EPIPE, Errno::ETIMEDOUT,
         # avoid a dependency on OpenSSL
         defined?(OpenSSL::SSL) ? OpenSSL::SSL::SSLError : IOError,
         Timeout::Error => exception
    if count < max_retries && IDEMPOTENT_METHODS_.include?(req.method)
      count += 1
      @socket.close if @socket
      debug "Conn close because of error #{exception}, and retry"
      retry
    end
    debug "Conn close because of error #{exception}"
    @socket.close if @socket
    raise
  end

  end_transport req, res
  res
rescue => exception
  debug "Conn close because of error #{exception}"
  @socket.close if @socket
  raise exception
end

# https://github.com/ruby/ruby/blob/master/lib/net/http/generic_request.rb
def exec(sock, ver, path)   #:nodoc: internal use only
  if @body
    send_request_with_body sock, ver, path, @body
  elsif @body_stream
    send_request_with_body_stream sock, ver, path, @body_stream
  elsif @body_data
    send_request_with_body_data sock, ver, path, @body_data
  else
    write_header sock, ver, path
  end
end

def send_request_with_body(sock, ver, path, body)
  self.content_length = body.bytesize
  delete 'Transfer-Encoding'
  supply_default_content_type
  write_header sock, ver, path
  wait_for_continue sock, ver if sock.continue_timeout
  sock.write body
end

def write_header(sock, ver, path)
  reqline = "#{@method} #{path} HTTP/#{ver}"
  if /[\r\n]/ =~ reqline
    raise ArgumentError, "A Request-Line must not contain CR or LF"
  end
  buf = +''
  buf << reqline << "\r\n"
  each_capitalized do |k,v|
    buf << "#{k}: #{v}\r\n"
  end
  buf << "\r\n"
  sock.write buf
end
