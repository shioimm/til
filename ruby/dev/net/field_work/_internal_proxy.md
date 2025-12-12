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
# (lib/net/http.rb)

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
# HTTP#connectにいたる経路
#   - Net::HTTP::Proxy => HTTP.start -> HTTP#start -> HTTP#do_start -> HTTP#connect
#   - HTTP.get -> HTTP.get_response` -> HTTP.start -> HTTP#start -> HTTP#do_start -> HTTP#connect
#   など

# (lib/net/http.rb)

def connect
  if use_ssl? # => HTTP#use_ssl?
    @ssl_context = OpenSSL::SSL::SSLContext.new
  end

  if proxy? # => HTTP#proxy?
    conn_addr = proxy_address # => HTTP#proxy_address
    conn_port = proxy_port # => HTTP#proxy_port
  else
    conn_addr = conn_address # => HTTP#conn_address
    conn_port = port # => attr_reader :port
  end

  # --- オリジンもしくはプロキシへTCP接続開始 ---
  s = Timeout.timeout(@open_timeout, Net::OpenTimeout) {
    begin
      # proxy? == trueの場合、プロキシに対してTCP接続を開始する
      TCPSocket.open(conn_addr, conn_port, @local_host, @local_port)
    rescue => e
      raise e, "Failed to open TCP connection to " +
        "#{conn_addr}:#{conn_port} (#{e.message})"
    end
  }

  s.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
  # --- TCP接続ここまで ---

  # プロキシを使用する場合、s = プロキシと接続済みの#<TCPSocket>

  # --- TLS接続 ---
  if use_ssl? # => HTTP#use_ssl?

    # --- フォワードプロキシ接続 ---
    if proxy?
      # @proxy_use_ssl = HTTP.Proxyを呼び出している場合は外部指定の値がセットされる
      # デフォルトではHTTP#initializeでnilがセットされている
      if @proxy_use_ssl
        # クライアント - プロキシ間をTLSで接続する (@proxy_use_ssl = trueの場合のみのオプション)
        proxy_sock = OpenSSL::SSL::SSLSocket.new(s)
        ssl_socket_connect(proxy_sock, @open_timeout) # => Net::Protocol#ssl_socket_connect (lib/net/protocol.rb)
      else
        proxy_sock = s
      end

      # proxy_sock = プロキシと接続済みの#<TCPSocket>あるいは#<OpenSSL::SSL::SSLSocket>

      proxy_sock = BufferedIO.new( # => Net::BufferedIO#initialize (lib/net/protocol.rb)
        proxy_sock,
        read_timeout: @read_timeout,
        write_timeout: @write_timeout,
        continue_timeout: @continue_timeout,
        debug_output: @debug_output
      )

      # オリジンの情報をプロキシに伝える
      buf = +"CONNECT #{conn_address}:#{@port} HTTP/#{HTTPVersion}\r\nHost: #{@address}:#{@port}\r\n"

      # 指定のアドレスがプロキシのものであり、該当のプロキシにユーザーが設定されている場合
      # もしくは外部指定のユーザーが設定されている場合
      if proxy_user # => HTTP#proxy_user
        credential = ["#{proxy_user}:#{proxy_pass}"].pack('m0')
        # => HTTP#proxy_user
        # => HTTP#proxy_pass
        buf << "Proxy-Authorization: Basic #{credential}\r\n" # CONNECTと同時に送信しても良い (RFC 7235)
      end

      buf << "\r\n"

      # プロキシに対してCONNECTリクエストを送信
      proxy_sock.write(buf) # => Net::BufferedIO#write
      # プロキシから HTTP/1.1 200 Connection Established を受け取る
      HTTPResponse.read_new(proxy_sock).value # => HTTPResponse.read_new レスポンスヘッダを読み込む
      # assuming nothing left in buffers after successful CONNECT response
    end
    # --- プロキシ接続ここまで ---

    ssl_parameters = Hash.new
    iv_list = instance_variables

    SSL_IVNAMES.each_with_index do |ivname, i|
      if iv_list.include?(ivname)
        value = instance_variable_get(ivname)

        if !value.nil?
          ssl_parameters[SSL_ATTRIBUTES[i]] = value
        end
      end
    end

    @ssl_context.set_params(ssl_parameters)

    if !@ssl_context.session_cache_mode.nil? # a dummy method on JRuby
      @ssl_context.session_cache_mode =
        OpenSSL::SSL::SSLContext::SESSION_CACHE_CLIENT | OpenSSL::SSL::SSLContext::SESSION_CACHE_NO_INTERNAL_STORE
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

    # --- クライアントからオリジンに対するTLS接続開始 ---
    s = OpenSSL::SSL::SSLSocket.new(s, @ssl_context)
    s.sync_close = true
    s.hostname = ssl_host_address if s.respond_to?(:hostname=) && ssl_host_address

    if @ssl_session and
       Process.clock_gettime(Process::CLOCK_REALTIME) < @ssl_session.time.to_f + @ssl_session.timeout
      s.session = @ssl_session
    end

    # CONNECTが完了している場合、s.connect (OpenSSL::SSL::SSLSocket#connect) を呼ぶと
    # 透過的にクライアントからオリジンに対して送信を行う
    ssl_socket_connect(s, @open_timeout) # => Net::Protocol#ssl_socket_connect (lib/net/protocol.rb)

    if (@ssl_context.verify_mode != OpenSSL::SSL::VERIFY_NONE) && verify_hostname
      s.post_connection_check(@address)
    end
  end
  # --- TLS接続ここまで ---

  @socket = BufferedIO.new( # => Net::BufferedIO#initialize (lib/net/protocol.rb)
    s, # TCPもしくはTLSで接続確立したソケット
    read_timeout: @read_timeout,
    write_timeout: @write_timeout,
    continue_timeout: @continue_timeout,
    debug_output: @debug_output
  )

  @last_communicated = nil
  on_connect
rescue => exception
  if s
    debug "Conn close because of connect error #{exception}"
    s.close
  end
  raise
end

# HTTP#use_ssl? (lib/net/http.rb)

def use_ssl?
  # HTTP#use_ssl= でセットする...忘れそう
  @use_ssl
end

# HTTP#proxy? (lib/net/http.rb)

def proxy?
  # HTTP::Proxyを呼び出している場合は@proxy_from_env = trueがセットされている
  !!(@proxy_from_env ? proxy_uri : @proxy_address)
  # @proxy_from_env, @proxy_addressいずれもHTTP,Proxyを呼び出した場合にセットされている。初期値はなし
  # => HTTP#proxy_uri
end

# HTTP#proxy_uri (lib/net/http.rb)

def proxy_uri # :nodoc:
  return if @proxy_uri == false

  @proxy_uri ||= URI::HTTP.new(
    "http", nil, address, port, nil, nil, nil, nil, nil
  ).find_proxy || false # => URI::Generic#find_proxy プロキシURIを返す

  @proxy_uri || nil
end

# HTTP#proxy_address (lib/net/http.rb)

def proxy_address
  if @proxy_from_env
    proxy_uri&.hostname # => HTTP#proxy_uri
  else
    @proxy_address
  end
end

# HTTP#proxy_port (lib/net/http.rb)

def proxy_port
  if @proxy_from_env
    proxy_uri&.port # => HTTP#proxy_uri
  else
    @proxy_port
  end
end

# HTTP#conn_address (lib/net/http.rb)

def conn_address # :nodoc:
  @ipaddr || address() # => attr_reader :address
end

# HTTP#proxy_user (lib/net/http.rb)

def proxy_user
  if @proxy_from_env
    user = proxy_uri&.user # => HTTP#proxy_uri / URI::Generic#user
    unescape(user) if user # => HTTP#unescape
  else
    # HTTP::Proxyを呼び出している場合は外部指定の値がセットされる
    # デフォルトではHTTP#initializeでnilがセットされている
    @proxy_user
  end
end

# HTTP#proxy_pass (lib/net/http.rb)

def proxy_pass
  if @proxy_from_env
    pass = proxy_uri&.password # => HTTP#proxy_uri / URI::Generic#password
    unescape(pass) if pass # => HTTP#unescape
  else
    # HTTP::Proxyを呼び出している場合は外部指定の値がセットされる
    # デフォルトではHTTP#initializeでnilがセットされている
    @proxy_pass
  end
end

# HTTP#unescape (lib/net/http.rb)

def unescape(value)
  require 'cgi/util'
  CGI.unescape(value) # URLデコードした文字列を新しく作成して返す
end
```

- `HTTP#request`が直接呼ばれた場合

```ruby
# HTTP#requestへの経路
# HTTP#request_get -> HTTP#request
# HTTP.new => HTTP#request

# (lib/net/http.rb)

def request(req, body = nil, &block)
  # @startedがfalseyなら内部でHTTP#connectを呼ぶことでプロキシまたはオリジンと接続を行う
  if !started? # @started => HTTP#started?
    start { # => HTTP#start -> HTTP#do_start -> HTTP#connect
      req['connection'] ||= 'close'
      return request(req, body, &block) # => HTTP#request (lib/net/http.rb)
    }
  end

  # プロキシを使用する、かつTLSでは接続しない場合
  if proxy_user && !use_ssl? # => HTTP#proxy_user / HTTP#use_ssl?
    # ヘッダにproxy-authorizationをセットする
    req.proxy_basic_auth(proxy_user, proxy_pass)
    # => HTTP#proxy_user
    # => HTTP#proxy_pass
    # => HTTPHeader#proxy_basic_auth
  end

  req.set_body_internal(body) # => HTTPGenericRequest#set_body_internal

  res = transport_request(req, &block) # => HTTP#transport_request

  if sspi_auth?(res) # => HTTP#sspi_auth?
    sspi_auth(req)
    res = transport_request(req, &block) # => HTTP#transport_request
  end

  res
end

# HTTPHeader#proxy_basic_auth (lib/net/http/header.rb)

def proxy_basic_auth(account, password)
  @header['proxy-authorization'] = [basic_encode(account, password)]
end

# HTTPHeader#basic_encode (lib/net/http/header.rb)

def basic_encode(account, password)
  'Basic ' + ["#{account}:#{password}"].pack('m0')
end
```
