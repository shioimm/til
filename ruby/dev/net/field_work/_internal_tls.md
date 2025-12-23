# net-http 現地調査: TLS編 (202512時点)

## HTTPSを利用する
- `HTTP#use_ssl=`を利用する

```ruby
uri = URI("https://example.com")

http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true

res = http.get("/")
puts res.body
```

- `use_ssl`オプションを渡す

```ruby
uri = URI.parse("https://example.com/")

Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
  res = http.get("/")
  puts res.body
end
```

- 明示的に設定を制御する

```ruby
uri = URI("https://example.com")

http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true

http.verify_hostname = true
http.verify_mode = OpenSSL::SSL::VERIFY_PEER
http.ca_file = "/etc/ssl/certs/ca-certificates.crt"
http.ca_path = "/etc/ssl/certs"
http.cert = OpenSSL::X509::Certificate.new(File.read("client.crt"))
http.key  = OpenSSL::PKey::RSA.new(File.read("client.key"))
http.min_version = OpenSSL::SSL::TLS1_2_VERSION
http.max_version = OpenSSL::SSL::TLS1_3_VERSION
http.ciphers = "TLS_AES_128_GCM_SHA256"
```

## HTTPSを使うための設定を保存する
#### `HTTP#use_ssl=`を利用する場合

```ruby
# HTTP#initialize (lib/net/http.rb)

SSL_ATTRIBUTES = [
  :ca_file,
  :ca_path,
  :cert,
  :cert_store,
  :ciphers,
  :extra_chain_cert,
  :key,
  :ssl_timeout,
  :ssl_version,
  :min_version,
  :max_version,
  :verify_callback,
  :verify_depth,
  :verify_mode,
  :verify_hostname,
] # :nodoc:

SSL_IVNAMES = SSL_ATTRIBUTES.map { |a| "@#{a}".to_sym } # :nodoc:

def initialize(address, port = nil) # :nodoc:
  defaults = {
    keep_alive_timeout: 2,
    close_on_empty_response: false,
    open_timeout: 60,
    read_timeout: 60,
    write_timeout: 60,
    continue_timeout: nil,
    max_retries: 1,
    debug_output: nil,
    response_body_encoding: false,
    ignore_eof: true
  }
  options = defaults.merge(self.class.default_configuration || {})

  @address = address
  @port    = (port || HTTP.default_port)
  @ipaddr = nil
  @local_host = nil
  @local_port = nil
  @curr_http_version = HTTPVersion
  @keep_alive_timeout = options[:keep_alive_timeout]
  @last_communicated = nil
  @close_on_empty_response = options[:close_on_empty_response]
  @socket  = nil
  @started = false
  @open_timeout = options[:open_timeout]
  @read_timeout = options[:read_timeout]
  @write_timeout = options[:write_timeout]
  @continue_timeout = options[:continue_timeout]
  @max_retries = options[:max_retries]
  @debug_output = options[:debug_output]
  @response_body_encoding = options[:response_body_encoding]
  @ignore_eof = options[:ignore_eof]

  @proxy_from_env = false
  @proxy_uri      = nil
  @proxy_address  = nil
  @proxy_port     = nil
  @proxy_user     = nil
  @proxy_pass     = nil
  @proxy_use_ssl  = nil

  @use_ssl = false
  @ssl_context = nil
  @ssl_session = nil
  @sspi_enabled = false

  SSL_IVNAMES.each do |ivname|
    instance_variable_set ivname, nil
  end
end

# HTTP#use_ssl= (lib/net/http.rb)

def use_ssl=(flag)
  flag = flag ? true : false # truthyならtrueになる

  if started? # @started (デフォルトではfalse) => HTTP#started? (lib/net/http.rb)
     and @use_ssl != flag # @use_sslもデフォルトではfalse
    raise IOError, "use_ssl value changed, but session already started"
  end

  # @use_sslに設定を保存する
  @use_ssl = flag
end
```

#### `Net::HTTP.start`に`use_ssl`オプションを渡す

WIP
```ruby
# (lib/net/http.rb)

def HTTP.start(address, *arg, &block) # :yield: +http+
  arg.pop if opt = Hash.try_convert(arg[-1])
  port, p_addr, p_port, p_user, p_pass = *arg
  p_addr = :ENV if arg.size < 2

  # 明示的な宛先ポートの指定がなく、use_sslキーワードに値を渡した場合
  port = https_default_port if !port && opt && opt[:use_ssl]
  # 443 => HTTP.https_default_port

  http = new(address, port, p_addr, p_port, p_user, p_pass) # => HTTP#initialize
  http.ipaddr = opt[:ipaddr] if opt && opt[:ipaddr]

  if opt
    if opt[:use_ssl]
      # use_sslがtruthyならoptにverify_modeをmergeする
      opt = {verify_mode: OpenSSL::SSL::VERIFY_PEER}.update(opt)
    end

    http.methods.grep(/\A(\w+)=\z/) do |meth| # => ふつうにObject#methodsだった
      # http.methods.grep(/\A(\w+)=\z/) = [
      #   # TLS関連の設定
      #     :ca_file=, :ca_path=, :cert_store=, # CA / 検証ストア
      #     :cert=, :key=, :extra_chain_cert=, # 証明書・鍵
      #     :ciphers=, :ssl_version=, :max_version=, :min_version=, # TLS バージョン
      #     :verify_callback=, :verify_depth=, :verify_hostname=, :verify_mode=, # 検証
      #     :use_ssl=, # TLSを利用する・しない
      #   # タイムアウトの設定
      #     :open_timeout=, :read_timeout=, :write_timeout=,
      #     :continue_timeout=, :keep_alive_timeout=, :ssl_timeout=,
      #   # プロキシ関連の設定
      #     :proxy_address=, :proxy_port=, :proxy_user=, :proxy_pass=, :proxy_use_ssl=, :proxy_from_env=,
      #   # 接続元に関する設定
      #     :local_host=, :local_port=, :ipaddr=,
      #   # 通信ロジックの挙動
      #     :max_retries=, :close_on_empty_response=, :ignore_eof=,
      #   # レスポンスのデコード
      #     :response_body_encoding=,
      # ]
      key = $1.to_sym
      opt.key?(key) or next
      http.__send__(meth, opt[key]) # なので、ここでHTTP#use_ssl=が呼ばれて@use_sslに設定が保存される
    end
  end

  http.start(&block) # => HTTP#start
end
```

## 保存したTLS設定を使う

```ruby
# HTTP#use_ssl? (lib/net/http.rb)

def use_ssl? # public
  @use_ssl
end
```

### `HTTP#use_ssl?`を参照している箇所
#### `HTTP#peer_cert`

```ruby
# (lib/net/http.rb)
# peer_certを返すための確認にHTTP#use_ssl?を使用している

def peer_cert # public
  # @socket = #<BufferedIO>
  if not use_ssl? or not @socket # => HTTP#use_ssl?
    return nil
  end

  # @socket.io = #<OpenSSL::SSL::SSLSocket>
  @socket.io.peer_cert # => OpenSSL::SSL::SSLSocket#peer_cert
end
```

#### `HTTP#request`

```ruby
# (lib/net/http.rb)
# - HTTP::Header#proxy_basic_authの設定が必要かを確認している
# - リクスト送信先の修正に利用している

def request(req, body = nil, &block)  # :yield: +response+
  unless started?
    start {
      req['connection'] ||= 'close'
      return request(req, body, &block)
    }
  end

  if proxy_user && !use_ssl? # => HTTP#use_ssl?
    req.proxy_basic_auth(proxy_user, proxy_pass)
  end

  req.set_body_internal body
  res = transport_request(req, &block) # => HTTP#transport_request

  if sspi_auth?(res)
    sspi_auth(req)
    res = transport_request(req, &block)
  end
  res
end

# (HTTP#request ->) HTTP::Header#proxy_basic_auth (lib/net/http/header.rb)

def proxy_basic_auth(account, password)
  @header['proxy-authorization'] = [basic_encode(account, password)] # => HTTP::Header#basic_encode
end

# HTTP::Header#basic_encode (lib/net/http/header.rb)

def basic_encode(account, password)
  'Basic ' + ["#{account}:#{password}"].pack('m0')
end

# (HTTP#request ->) HTTP#transport_request (lib/net/http.rb)

def transport_request(req)
  count = 0
  begin
    begin_transport req  # => HTTP#begin_transport
    res = catch(:response) {
      begin
        req.exec(@socket, @curr_http_version, edit_path(req.path)) # => HTTP#edit_path
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

# (HTTP#request -> HTTP#transport_request ->) HTTP#begin_transport (lib/net/http.rb)

def begin_transport(req)
  if @socket.closed?
    connect
  elsif @last_communicated
    if @last_communicated + @keep_alive_timeout < Process.clock_gettime(Process::CLOCK_MONOTONIC)
      debug 'Conn close because of keep_alive_timeout'
      @socket.close
      connect
    elsif @socket.io.to_io.wait_readable(0) && @socket.eof?
      debug "Conn close because of EOF"
      @socket.close
      connect
    end
  end

  if not req.response_body_permitted? and @close_on_empty_response
    req['connection'] ||= 'close'
  end

  req.update_uri(address, port, use_ssl?) # => HTTPGenericRequest#update_uri
  req['host'] ||= addr_port()
end

# (HTTP#request -> HTTP#transport_request -> HTTP#begin_transport) HTTPGenericRequest#update_uri

def update_uri(addr, port, ssl) # :nodoc: internal use only
  # reflect the connection and @path to @uri
  return unless @uri

  if ssl # ここでHTTP#use_ssl?の結果をを参照している
    scheme = 'https'
    klass = URI::HTTPS
  else
    scheme = 'http'
    klass = URI::HTTP
  end

  if host = self['host']
    host.sub!(/:.*/m, '')
  elsif host = @uri.host
  else
   host = addr
  end

  # convert the class of the URI
  if @uri.is_a?(klass)
    @uri.host = host
    @uri.port = port
  else
    @uri = klass.new(
      scheme, @uri.userinfo,
      host, port, nil,
      @uri.path, nil, @uri.query, nil)
  end
end

# (HTTP#request -> HTTP#transport_request ->) HTTP#edit_path (lib/net/http.rb)

def edit_path(path)
  if proxy?
    if path.start_with?("ftp://") || use_ssl? # => HTTP#use_ssl?
      path
    else
      "http://#{addr_port}#{path}"
    end
  else
    path
  end
end

# (HTTP#request -> HTTP#transport_request -> HTTP#edit_path ->) HTTP#addr_port (lib/net/http.rb)

def addr_port
  addr = address
  addr = "[#{addr}]" if addr.include?(":")
  default_port = use_ssl? ? HTTP.https_default_port : HTTP.http_default_port # => HTTP#use_ssl?
  default_port == port ? addr : "#{addr}:#{port}"
end
```

#### `HTTP#connect`

```ruby
# (lib/net/http.rb)
# OpenSSLを利用して実際にTLSで接続するために利用している

def connect
  # #<OpenSSL::SSL::SSLContext>を作成
  if use_ssl? # => HTTP#use_ssl?
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

  if use_ssl? # => HTTP#use_ssl?
    # --- プロキシの設定 ---
    if proxy? # プロキシ先にTLSで接続
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

    # --- プロキシの設定ここまで ---

    ssl_parameters = Hash.new
    iv_list = instance_variables

    # SSL_IVNAMES = SSL_ATTRIBUTES.map { |a| "@#{a}".to_sym } # :nodoc:
    # SSL_ATTRIBUTES = [
    #   # CA / 検証ストア
    #   :ca_file, :ca_path, :cert_store,
    #   # 証明書・鍵
    #   :cert, :key, :extra_chain_cert,
    #   # TLSバージョン
    #   :ciphers, :ssl_version, :min_version, :max_version,
    #   # タイムアウトの設定
    #   :ssl_timeout,
    #   # 検証
    #   :verify_callback, :verify_depth, :verify_mode, :verify_hostname,
    # ] # :nodoc:
    SSL_IVNAMES.each_with_index do |ivname, i|
      if iv_list.include?(ivname)
        value = instance_variable_get(ivname)

        if !value.nil?
          ssl_parameters[SSL_ATTRIBUTES[i]] = value
        end
      end
    end

    # #<OpenSSL::SSL::SSLContext>に設定を保存する
    @ssl_context.set_params(ssl_parameters)

    # クライアント側からTLSセッション再開を有効にする。OpenSSLの内部セッションキャッシュは使わない。
    # (JRubyでは何もしない)
    if !@ssl_context.session_cache_mode.nil? # a dummy method on JRuby
      @ssl_context.session_cache_mode =
        # クライアント側セッションをキャッシュに追加する
        OpenSSL::SSL::SSLContext::SESSION_CACHE_CLIENT |
        # セッションキャッシュをOpenSSL::SSL::SSLContext内部のキャッシュ領域に保持しない
        OpenSSL::SSL::SSLContext::SESSION_CACHE_NO_INTERNAL_STORE
    end

    # 新しく確立したTLSセッションを保存する (次回接続で再利用するため) コールバックを
    # @ssl_context.session_new_cbに登録
    if @ssl_context.respond_to?(:session_new_cb) # not implemented under JRuby
      @ssl_context.session_new_cb = proc {|sock, sess| @ssl_session = sess }
    end

    # Still do the post_connection_check below even if connecting
    # to IP address (接続先がIPアドレスの場合もTLS接続後のホスト名を検証する)
    verify_hostname = @ssl_context.verify_hostname

    # Server Name Indication (SNI) RFC 3546/6066
    #   ClientHelloに接続先ホスト名を含める仕組み
    #   同一のIPで複数のドメインをホストしているサーバが正しい証明書を選択できるようにする
    case @address
    when Resolv::IPv4::Regex, Resolv::IPv6::Regex
      # don't set SNI, as IP addresses in SNI is not valid
      # per RFC 6066, section 3.

      # Avoid openssl warning
      @ssl_context.verify_hostname = false # 宛先がIPアドレス形式の場合はSNIを送らない
    else
      ssl_host_address = @address
    end

    debug "starting SSL for #{conn_addr}:#{conn_port}..."

    s = OpenSSL::SSL::SSLSocket.new(s, @ssl_context) # TCP接続済みの#<TCPSocket>を渡す

    # SSLSocketをcloseした場合、内部のTCPSocketも同時にcloseする => OpenSSL::SSL::SSLSocket#sync_close=
    s.sync_close = true
    # SNIの設定 => OpenSSL::SSL::SSLSocket#hostname=
    s.hostname = ssl_host_address if s.respond_to?(:hostname=) && ssl_host_address

    # セッションを再開する場合
    if @ssl_session and
       Process.clock_gettime(Process::CLOCK_REALTIME) < @ssl_session.time.to_f + @ssl_session.timeout
      s.session = @ssl_session # => OpenSSL::SSL::SSLSocket#session=
    end

    ssl_socket_connect(s, @open_timeout) # => Net::Protocol#ssl_socket_connect (lib/net/protocol.rb)

    # 証明書のホスト名を検証する
    if (@ssl_context.verify_mode != OpenSSL::SSL::VERIFY_NONE) && verify_hostname
      s.post_connection_check(@address) # => OpenSSL::SSL::SSLSocket#post_connection_check
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
