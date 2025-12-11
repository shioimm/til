# net-http 現地調査: プロキシ編 (202512時点)
- `Net::HTTP.Proxy`を経由してプロキシの設定ができる

```ruby
proxy = Net::HTTP::Proxy("proxy.example.com", 8080)

http = proxy.new("example.com")
http.start { it.get("/ja/") }

# or
proxy.start("example.com") { it.get("/ja/") }

# => HTTP.start -> HTTP#start -> HTTP#do_start -> HTTP#connect
```

```ruby
(lib/net/http.rb)

def HTTP.Proxy(p_addr = :ENV, p_port = nil, p_user = nil, p_pass = nil, p_use_ssl = nil) #:nodoc:
  return self unless p_addr

  Class.new(self) { # self = HTTP
    @is_proxy_class = true

    if p_addr == :ENV then
      @proxy_from_env = true
      @proxy_address = nil
      @proxy_port    = nil
    else
      @proxy_from_env = false
      @proxy_address = p_addr
      @proxy_port    = p_port || default_port
    end

    @proxy_user = p_user
    @proxy_pass = p_pass
    @proxy_use_ssl = p_use_ssl
  }
end
```

- `HTTP#connect`内でプロキシの設定を行う


```ruby
# HTTP#connectへの経路
#   - Net::HTTP::Proxy -> HTTP.start -> HTTP#start -> HTTP#do_start -> HTTP#connect
#   - HTTP.get -> HTTP.get_response` -> HTTP.start -> HTTP#start -> HTTP#do_start -> HTTP#connect
#   など

# (lib/net/http.rb)

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
```

## 要確認
- `HTTP#request`が直接呼ばれた場合どうなるか
