# net-http 現地調査 (202509時点)
https://github.com/ruby/ruby/blob/master/lib/net/http.rb

## 全体の流れ
- `HTTP.get` public
  - `HTTP.get_response` public
    - `HTTP#initialize`
    - `HTTP.start` / `HTTP#start` public
      - `HTTP#do_start`
        - `HTTP#connect`
          - `TCPSocket.open` TCP接続
          - (TLS接続の場合) `OpenSSL::SSL::SSLSocket.new`
          - (TLS接続の場合) `Net::Protocol#ssl_socket_connect`
          - `@socket = BufferedIO.new` TCPもしくはTLSで接続確立したソケットをBufferedIOでラップする
    - `HTTP#request_get` public
      - `HTTPRequest#initialize` -> `HTTPGenericRequest#initialize`
        - `HTTPHeader#initialize_http_header` リクエストヘッダをセット
      - `HTTP#request` public
        - `HTTPGenericRequest#set_body_internal` リクエストボディをセット
        - `HTTP#transport_request` リクエストの送信を行う
          - `HTTP#begin_transport`
            - `HTTPGenericRequest#update_uri` `@uri = URI::HTTPS or URI::HTTP.new`をセット
          - `HTTP::{{各HTTPメソッドを表すクラス}}#exec` -> `HTTPGenericRequest#exec` リクエストを送信する
            - `HTTPGenericRequest#send_request_with_body`
              - `HTTPGenericRequest#supply_default_content_type`
              - `HTTPGenericRequest#write_header`
              - `sock.write`
            - `HTTPGenericRequest#send_request_with_body_stream`
              - `HTTPGenericRequest#supply_default_content_type`
              - `HTTPGenericRequest#write_header`
              - `IO.copy_stream`
            - `HTTPGenericRequest#send_request_with_body_data`
              - `HTTPGenericRequest#write_header`
            - `HTTPGenericRequest#write_header`
          - `HTTPResponse.read_new` レスポンスヘッダを読み込む
            - `HTTPResponse.read_status_line`
            - `HTTPResponse.response_class`
            - `HTTPResponse.each_response_header`
              - `HTTPHeader#add_field`
          - `HTTPResponse#reading_body` レスポンスボディを読み込む
            - `HTTPResponse#body`
              - `HTTPResponse#read_body`
                - `HTTPResponse#read_body_0`
                  - `HTTPResponse#inflater`
                  - (圧縮あり) `HTTPResponse::Inflater#read`
                    - `HTTPResponse::Inflater#inflate_adapter`
                    - `Net::BufferedIO#read`
                  - (圧縮あり) `HTTPResponse::Inflater#read_all`
                    - `HTTPResponse::Inflater#inflate_adapter`
                    - `Net::BufferedIO#read_all`
                  - (圧縮なし) `Net::BufferedIO#read`
                    - `Net::BufferedIO#rbuf_fill`
                    - `Net::BufferedIO#rbuf_consume`
                  - (圧縮なし) `Net::BufferedIO#read_all`
                    - `Net::BufferedIO#rbuf_fill`
                - `HTTPResponse#detect_encoding`
                - `String#force_encoding`
          - `HTTP#end_transport` 後処理

### 気づいたこと
- `HTTP#start` -> `HTTP#do_start` -> `HTTP#connect`で接続を行う
- `HTTP#do_start`実行後に`HTTP#request`を呼び出す
  - `HTTP#request`に`各HTTPメソッドを表すクラス`のオブジェクトを渡す
  - `HTTP#request`
    - -> `HTTP#transport_request`
    - -> `HTTP#begin_transport`, `HTTP::{{各HTTPメソッドを表すクラス}}#exec` `HTTP#end_transport`
- 返り値は各HTTPステータスを表すクラスのオブジェクトの場合が多い (`Net::HTTP.get`以外)
- すでにresolvライブラリに依存している
- べんりライブラリnet/protocolに依存している
- パブリックなメソッドが多い、外から制御できる設定値も多い

## `HTTP.get`

```ruby
# (lib/net/http.rb)

def HTTP.get(uri_or_host, path_or_headers = nil, port = nil)
  get_response(uri_or_host, path_or_headers, port).body
  # => HTTP.get_response (lib/net/http.rb)
  # => HTTPResponse#body (lib/net/http/response.rb)
end
```

## `HTTP.get_response`

```ruby
# (lib/net/http.rb)

def HTTP.get_response(uri_or_host, path_or_headers = nil, port = nil, &block)
  if path_or_headers && !path_or_headers.is_a?(Hash)
    # Net::HTTP.get_response("www.example.com", "index.html")
    # HTTPSは使わないパターン

    host = uri_or_host
    path = path_or_headers

    new(host, port || HTTP.default_port).start { |http|
      return http.request_get(path, &block) # => HTTP#request_get
    }
    # => HTTP#initialize
    # => HTTP#start
  else
    # Net::HTTP.get_response(URI("https://www.example.com/index.html"), { "Accept" => "text/html" })

    uri = uri_or_host
    headers = path_or_headers

    start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https') { |http|
      return http.request_get(uri, headers, &block) # => HTTP#request_get
    }
    # => HTTP.start (lib/net/http.rb)
  end
end

# HTTP#initialize (lib/net/http.rb)

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
```

## `HTTP.start`

```ruby
# (lib/net/http.rb)

def HTTP.start(address, *arg, &block) # :yield: +http+
  arg.pop if opt = Hash.try_convert(arg[-1])
  port, p_addr, p_port, p_user, p_pass = *arg
  p_addr = :ENV if arg.size < 2
  port = https_default_port if !port && opt && opt[:use_ssl]
  # 443 => HTTP.https_default_port

  http = new(address, port, p_addr, p_port, p_user, p_pass) # => HTTP#initialize
  http.ipaddr = opt[:ipaddr] if opt && opt[:ipaddr]

  if opt
    if opt[:use_ssl]
      opt = {verify_mode: OpenSSL::SSL::VERIFY_PEER}.update(opt)
    end

    http.methods.grep(/\A(\w+)=\z/) do |meth| # => HTTP#methods (?)
      key = $1.to_sym
      opt.key?(key) or next
      http.__send__(meth, opt[key])
    end
  end

  http.start(&block) # => HTTP#start
end
```

## HTTP#start (lib/net/http.rb)

```ruby
# (lib/net/http.rb)

def start
  raise IOError, 'HTTP session already opened' if @started

  if block_given?
    begin
      do_start # => HTTP#do_start
      return yield(self) # 呼び出し側ではブロック内でHTTP#request_getを呼んでいる
    ensure
      do_finish # => HTTP#do_finish

      # HTTP#do_finish (lib/net/http.rb)
      #   def do_finish
      #     @started = false
      #     @socket.close if @socket
      #     @socket = nil
      #   end
    end
  end

  do_start # => HTTP#do_start
  self
end

# HTTP#do_start (lib/net/http.rb)

def do_start
  connect # => HTTP#connect
  @started = true
end

# HTTP#connect (lib/net/http.rb)

def connect
  if use_ssl? # @use_ssl => HTTP#use_ssl (lib/net/http.rb)
    # reference early to load OpenSSL before connecting,
    # as OpenSSL may take time to load.
    @ssl_context = OpenSSL::SSL::SSLContext.new
  end

  if proxy? then
    conn_addr = proxy_address # => HTTP#proxy_address

    conn_port = proxy_port # => HTTP#proxy_port
  else
    conn_addr = conn_address # => HTTP#conn_address
    conn_port = port # => attr_reader :port
  end

  # --- TCP接続 ---
  debug "opening connection to #{conn_addr}:#{conn_port}..."

  s = Timeout.timeout(@open_timeout, Net::OpenTimeout) {
    begin
      TCPSocket.open(conn_addr, conn_port, @local_host, @local_port)
    rescue => e
      raise e, "Failed to open TCP connection to " + "#{conn_addr}:#{conn_port} (#{e.message})"
    end
  }

  s.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)

  debug "opened"
  # --- TCP接続ここまで ---

  # --- TLS接続 ---
  if use_ssl? # @use_ssl => HTTP#use_ssl (lib/net/http.rb)

    # --- フォワードプロキシ接続 ---
    if proxy? # !!(@proxy_from_env ? proxy_uri : @proxy_address) => HTTP#proxy? (lib/net/http.rb)

      if @proxy_use_ssl # プロキシに対してTLSで接続
        proxy_sock = OpenSSL::SSL::SSLSocket.new(s)
        ssl_socket_connect(proxy_sock, @open_timeout) # => Net::Protocol#ssl_socket_connect (lib/net/protocol.rb)
      else
        proxy_sock = s
      end

      proxy_sock = BufferedIO.new( # => Net::BufferedIO#initialize (lib/net/protocol.rb)
        proxy_sock,
        read_timeout: @read_timeout,
        write_timeout: @write_timeout,
        continue_timeout: @continue_timeout,
        debug_output: @debug_output
      )

      buf = +"CONNECT #{conn_address}:#{@port} HTTP/#{HTTPVersion}\r\nHost: #{@address}:#{@port}\r\n"

      if proxy_user
        credential = ["#{proxy_user}:#{proxy_pass}"].pack('m0')
        buf << "Proxy-Authorization: Basic #{credential}\r\n"
      end

      buf << "\r\n"
      proxy_sock.write(buf)
      HTTPResponse.read_new(proxy_sock).value
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
      # don't set SNI, as IP addresses in SNI is not valid per RFC 6066, section 3.

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

    # オリジンサーバに対してTLSで接続
    ssl_socket_connect(s, @open_timeout) # => Net::Protocol#ssl_socket_connect (lib/net/protocol.rb)

    if (@ssl_context.verify_mode != OpenSSL::SSL::VERIFY_NONE) && verify_hostname
      s.post_connection_check(@address)
    end

    debug "SSL established, protocol: #{s.ssl_version}, cipher: #{s.cipher[0]}"
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
  on_connect # => 空っぽだった...
rescue => exception
  if s
    debug "Conn close because of connect error #{exception}"
    s.close
  end

  raise
end
```

## `HTTP#request_get`

```ruby
# (lib/net/http.rb)

# path       = #<URI::HTTPS https://www.example.com/index.html>
# initheader = { "Accept" => "text/html" }
def request_get(path, initheader = nil, &block) # :yield: +response+
  # class Get は class Net::HTTPRequest < Net::HTTPGenericRequest で定義されている
  request(Get.new(path, initheader), &block)
  # => HTTP#request
  # => HTTPRequest#initialize
end

# HTTPRequest#initialize (lib/net/http/request.rb)

def initialize(path, initheader = nil)
  super self.class::METHOD,
        self.class::REQUEST_HAS_BODY,  # リクエストメソッド別クラスごとにtrue / falseで定義されていた...
        self.class::RESPONSE_HAS_BODY, # こっちも...
        path, initheader
end

# HTTPGenericRequest#initialize (lib/net/http/generic_request.rb)

 def initialize(m, reqbody, resbody, uri_or_path, initheader = nil) # :nodoc:
    @method = m
    @request_has_body = reqbody
    @response_has_body = resbody

    if URI === uri_or_path then
      raise ArgumentError, "not an HTTP URI" unless URI::HTTP === uri_or_path

      hostname = uri_or_path.hostname
      raise ArgumentError, "no host component for URI" unless (hostname && hostname.length > 0)
      @uri = uri_or_path.dup
      host = @uri.hostname.dup
      host << ":" << @uri.port.to_s if @uri.port != @uri.default_port
      @path = uri_or_path.request_uri
      raise ArgumentError, "no HTTP request path given" unless @path

    else

      @uri = nil
      host = nil
      raise ArgumentError, "no HTTP request path given" unless uri_or_path
      raise ArgumentError, "HTTP request path is empty" if uri_or_path.empty?
      @path = uri_or_path.dup

    end

    @decode_content = false

    # zlibがある環境、かつ実行時に外部からヘッダが指定されていないかAccept-EncodingかRangeを設定していない場合
    if Net::HTTP::HAVE_ZLIB && (
      !initheader ||
      !initheader.keys.any? { |k| %w[accept-encoding range].include? k.downcase }
    )
      @decode_content = true if @response_has_body
      initheader = initheader ? initheader.dup : {}
      # Accept-Encoding: gzip, deflate, identityを自動で付与し、受信時に解凍できるようにする
      initheader["accept-encoding"] = "gzip;q=1.0,deflate;q=0.6,identity;q=0.3"
    end

    initialize_http_header initheader # => HTTPHeader#initialize_http_header

    self['Accept'] ||= '*/*'
    self['User-Agent'] ||= 'Ruby'
    self['Host'] ||= host if host
    @body = nil
    @body_stream = nil
    @body_data = nil
  end
end

# HTTPHeader#initialize_http_header (lib/net/http/header.rb)

def initialize_http_header(initheader)
  @header = {}
  return unless initheader

  initheader.each do |key, value|
    if value.nil?
      warn "net/http: nil HTTP header: #{key}", uplevel: 3 if $VERBOSE
    else
      value = value.strip # raise error for invalid byte sequences

      if key.to_s.bytesize > MAX_KEY_LENGTH
        raise ArgumentError, "too long (#{key.bytesize} bytes) header: #{key[0, 30].inspect}..."
      end

      if value.to_s.bytesize > MAX_FIELD_LENGTH
        raise ArgumentError, "header #{key} has too long field value: #{value.bytesize}"
      end

      if value.count("\r\n") > 0
        raise ArgumentError, "header #{key} has field value #{value.inspect}, this cannot include CR/LF"
      end

      @header[key.downcase.to_s] = [value]
    end
  end
end
```

### `HTTP#request`

```ruby
# (lib/net/http.rb)

# req = #<Net::HTTP::Get GET>
# req.instance_variables
#   => [:@method,
#       :@request_has_body,
#       :@response_has_body,
#       :@uri,
#       :@path,
#       :@decode_content,
#       :@header,
#       :@body,
#       :@body_stream,
#       :@body_data]
def request(req, body = nil, &block)
  if !started? # @started => HTTP#started? (lib/net/http.rb)
    start { # => HTTP#start (lib/net/http.rb)
      req['connection'] ||= 'close'
      return request(req, body, &block) # => HTTP#request (lib/net/http.rb)
    }
  end

  if proxy_user && !use_ssl?
    req.proxy_basic_auth(proxy_user, proxy_pass)
  end

  req.set_body_internal(body) # => HTTPGenericRequest#set_body_internal

  res = transport_request(req, &block) # => HTTP#transport_request

  if sspi_auth?(res) # => HTTP#sspi_auth?

    # HTTP#sspi_auth? (lib/net/http.rb)
    #
    #   def sspi_auth?(res)
    #     return false unless @sspi_enabled
    #     if res.kind_of?(HTTPProxyAuthenticationRequired) and
    #         proxy? and res["Proxy-Authenticate"].include?("Negotiate")
    #       begin
    #         require 'win32/sspi'
    #         true
    #       rescue LoadError
    #         false
    #       end
    #     else
    #       false
    #     end
    #   end

    sspi_auth(req)
    res = transport_request(req, &block) # => HTTP#transport_request
  end

  res
end


# HTTPGenericRequest#set_body_internal (lib/net/http/generic_request.rb)

def set_body_internal(str)
  raise ArgumentError, "both of body argument and HTTPRequest#body set" if str and (@body or @body_stream)
  # どういう状況?と思ったらHTTPGenericRequest#body=もしくは#body_stream=で値がセットされていることがあるらしい
  # 柔軟すぎでは????

  self.body = str if str # => HTTPGenericRequest#body=

  if @body.nil? && @body_stream.nil? && @body_data.nil? && request_body_permitted?
    self.body = '' # => HTTPGenericRequest#body=
  end
end

# HTTPGenericRequest#body= (lib/net/http/generic_request.rb)

def body=(str)
  @body = str
  @body_stream = nil
  @body_data = nil
  str
end

# HTTP#transport_request (lib/net/http.rb)

# req = #<Net::HTTP::Get GET>
# req.instance_variables
#   => [:@method,
#       :@request_has_body,
#       :@response_has_body,
#       :@uri,
#       :@path,
#       :@decode_content,
#       :@header,
#       :@body,
#       :@body_stream,
#       :@body_data]
def transport_request(req)
  count = 0

  begin
    begin_transport req # => HTTP#begin_transport

    res = catch(:response) {
      begin
        # @socketにリクエストを書き込む
        req.exec(@socket, @curr_http_version, edit_path(req.path)) # => HTTPGenericRequest#exec
      rescue Errno::EPIPE
        # Failure when writing full request, but we can probably
        # still read the received response.
      end

      begin
        # @socket からレスポンスを読み込む
        res = HTTPResponse.read_new(@socket) # => HTTPResponse.read_new

        res.decode_content = req.decode_content
        res.body_encoding = @response_body_encoding
        res.ignore_eof = @ignore_eof
      end while res.kind_of?(HTTPInformation)

      res.uri = req.uri

      res
    }

    res.reading_body(@socket, req.response_body_permitted?) { # => HTTPResponse#reading_body
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

  end_transport req, res # => HTTP#end_transport
  res
rescue => exception
  debug "Conn close because of error #{exception}"
  @socket.close if @socket
  raise exception
end

# HTTP#begin_transport (lib/net/http.rb)

def begin_transport(req)
  if @socket.closed? # ソケットが閉じている場合は接続しなおす
    connect # => HTTP#connect
  elsif @last_communicated # 過去にtransport_requestを実行している場合

    if @last_communicated + @keep_alive_timeout < Process.clock_gettime(Process::CLOCK_MONOTONIC)
      # Keep-Aliveがタイムアウトしている場合はソケットを閉じて接続し直す
      debug 'Conn close because of keep_alive_timeout'
      @socket.close
      connect # => HTTP#connect
    elsif @socket.io.to_io.wait_readable(0) && @socket.eof?
      # ソケットがEOFの場合はソケットを閉じて接続し直す
      debug "Conn close because of EOF"
      @socket.close
      connect # => HTTP#connect
    end

  end

  if not req.response_body_permitted? and @close_on_empty_response
    # @response_has_body => HTTPGenericRequest#response_body_permitted? (lib/net/http/generic_request.rb)
    req['connection'] ||= 'close'
  end

  req.update_uri address, port, use_ssl? # => HTTPGenericRequest#update_uri
  req['host'] ||= addr_port() # => HTTP#addr_port

  # HTTP#addr_port (lib/net/http.rb)
  #
  #   def addr_port
  #     addr = address
  #     addr = "[#{addr}]" if addr.include?(":")
  #     default_port = use_ssl? ? HTTP.https_default_port : HTTP.http_default_port
  #     default_port == port ? addr : "#{addr}:#{port}"
  #   end
end

# HTTPGenericRequest#update_uri (lib/net/http/generic_request.rb)

def update_uri(addr, port, ssl)
  # reflect the connection and @path to @uri
  return unless @uri

  if ssl
    scheme = 'https'
    klass = URI::HTTPS
  else
    scheme = 'http'
    klass = URI::HTTP
  end

  if host = self['host']
    host.sub!(/:.*/m, '')
  elsif host = @uri.host
    # do nothing
  else
   host = addr
  end

  # @uriにはHTTPGenericRequest#initialize時にuri_or_pathが格納されている
  if @uri.is_a?(klass) # URI::HTTPS or URI::HTTP
    @uri.host = host
    @uri.port = port
  else
    @uri = klass.new( # URI::HTTPS or URI::HTTP
      scheme,
      @uri.userinfo,
      host, port, nil,
      @uri.path, nil, @uri.query, nil
    )
  end
end

# HTTPGenericRequest#exec (lib/net/http/generic_request.rb)

def exec(sock, ver, path)
  if @body # HTTPGenericRequest#set_body_internalか、外部からHTTPGenericRequest#body=が呼ばれた場合
    send_request_with_body sock, ver, path, @body # => HTTPGenericRequest#send_request_with_body
  elsif @body_stream # 外部からHTTPGenericRequest#body_stream=が呼ばれた場合。ボディがIOストリーム
    send_request_with_body_stream sock, ver, path, @body_stream # => HTTPGenericRequest#send_request_with_body_stream
  elsif @body_data # よくわからない
    send_request_with_body_data sock, ver, path, @body_data # => HTTPGenericRequest#send_request_with_body_data
  else
    write_header sock, ver, path # => HTTPGenericRequest#write_header
  end
end

# HTTPGenericRequest#send_request_with_body (lib/net/http/generic_request.rb)

def send_request_with_body(sock, ver, path, body)
  self.content_length = body.bytesize
  delete 'Transfer-Encoding'
  supply_default_content_type # => HTTPGenericRequest#supply_default_content_type
  write_header sock, ver, path # => HTTPGenericRequest#write_header
  wait_for_continue sock, ver if sock.continue_timeout # => HTTPGenericRequest#wait_for_continue
  sock.write body
end

# HTTPGenericRequest#supply_default_content_type (lib/net/http/generic_request.rb)

def supply_default_content_type
  return if content_type() # => HTTPHeader#content_type
  set_content_type 'application/x-www-form-urlencoded' # => HTTPHeader#set_content_type
end

# HTTPHeader#content_type (lib/net/http/header.rb)

def content_type
  main = main_type() # => HTTPHeader#main_type

  # HTTPHeader#main_type (lib/net/http/header.rb)
  #
  #   def main_type
  #     return nil unless @header['content-type']
  #     self['Content-Type'].split(';').first.to_s.split('/')[0].to_s.strip
  #   end

  return nil unless main

  sub = sub_type()

  # HTTPHeader#sub_type (lib/net/http/header.rb)
  #
  #   def sub_type
  #     return nil unless @header['content-type']
  #     _, sub = *self['Content-Type'].split(';').first.to_s.split('/')
  #     return nil unless sub
  #     sub.strip
  #   end

  if sub
    "#{main}/#{sub}"
  else
    main
  end
end

# HTTPHeader#set_content_type (lib/net/http/header.rb)

def set_content_type(type, params = {})
  @header['content-type'] = [type + params.map{|k,v|"; #{k}=#{v}"}.join('')]
end

# HTTPGenericRequest#wait_for_continue (lib/net/http/generic_request.rb)

def wait_for_continue(sock, ver)
  if ver >= '1.1' and @header['expect'] and @header['expect'].include?('100-continue')
    if sock.io.to_io.wait_readable(sock.continue_timeout)
      res = Net::HTTPResponse.read_new(sock)

      unless res.kind_of?(Net::HTTPContinue)
        res.decode_content = @decode_content # => HTTPResponseインスタンスの@decode_contentに対する設定
        throw :response, res
      end
    end
  end
end

# HTTPGenericRequest#send_request_with_body_stream (lib/net/http/generic_request.rb)

def send_request_with_body_stream(sock, ver, path, f)
  unless content_length() or chunked?
    raise ArgumentError, "Content-Length not given and Transfer-Encoding is not `chunked'"
  end

  supply_default_content_type # => HTTPGenericRequest#supply_default_content_type
  write_header sock, ver, path # => HTTPGenericRequest#write_header
  wait_for_continue sock, ver if sock.continue_timeout # => HTTPGenericRequest#wait_for_continue

  if chunked?
    # HTTPHeader#chunked? (lib/net/http/header.rb)
    #
    #   def chunked?
    #     return false unless @header['transfer-encoding']
    #     field = self['Transfer-Encoding']
    #     (/(?:\A|[^\-\w])chunked(?![\-\w])/i =~ field) ? true : false
    #   end

    chunker = Chunker.new(sock)
    IO.copy_stream(f, chunker)
    chunker.finish
  else
    IO.copy_stream(f, sock)
  end
end

# HTTPGenericRequest#send_request_with_body_data (lib/net/http/generic_request.rb)

def send_request_with_body_data(sock, ver, path, params)
  if /\Amultipart\/form-data\z/i !~ self.content_type
    self.content_type = 'application/x-www-form-urlencoded'
    return send_request_with_body(sock, ver, path, URI.encode_www_form(params))
    # => HTTPGenericRequest#send_request_with_body
  end

  opt = @form_option.dup
  require 'securerandom' unless defined?(SecureRandom)
  opt[:boundary] ||= SecureRandom.urlsafe_base64(40)
  self.set_content_type(self.content_type, boundary: opt[:boundary])

  if chunked?
    write_header sock, ver, path # => HTTPGenericRequest#write_header
    encode_multipart_form_data(sock, params, opt)
  else
    require 'tempfile'
    file = Tempfile.new('multipart')
    file.binmode
    encode_multipart_form_data(file, params, opt)
    file.rewind
    self.content_length = file.size

    write_header sock, ver, path # => HTTPGenericRequest#write_header
    IO.copy_stream(file, sock)
    file.close(true)
  end
end

# HTTPGenericRequest#write_header (lib/net/http/generic_request.rb)

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

# HTTPResponse.read_new (lib/net/http/response.rb)

def read_new(sock)
  # ステータスラインを取得
  httpv, code, msg = read_status_line(sock) # => HTTPResponse.read_status_line

  # ここでレスポンスステータスごとにクラスが分かれている
  res = response_class(code).new(httpv, code, msg) # => HTTPResponse.response_class

  each_response_header(sock) do |k,v| # => HTTPResponse.each_response_header
    res.add_field k, v # => HTTPHeader#add_field
  end

  res
end

# HTTPResponse.read_status_line (lib/net/http/response.rb)

def read_status_line(sock)
  str = sock.readline
  m = /\AHTTP(?:\/(\d+\.\d+))?\s+(\d\d\d)(?:\s+(.*))?\z/in.match(str) or
    raise Net::HTTPBadResponse, "wrong status line: #{str.dump}"
  m.captures
end

# HTTPResponse.response_class (lib/net/http/response.rb)

def response_class(code)
  CODE_TO_OBJ[code] or            # Net::HTTPResponse::CODE_TO_OBJとして定義されている
  CODE_CLASS_TO_OBJ[code[0,1]] or # Net::HTTPResponse::CODE_CLASS_TO_OBJとして定義されている
  Net::HTTPUnknownResponse
end

# HTTPResponse.each_response_header (lib/net/http/response.rb)

def each_response_header(sock)
  key = value = nil

  while true
    line = sock.readuntil("\n", true).sub(/\s+\z/, '')

    break if line.empty?

    if line[0] == ?\s or line[0] == ?\t and value
      value << ' ' unless value.empty?
      value << line.strip
    else
      yield key, value if key
      key, value = line.strip.split(/\s*:\s*/, 2)
      raise Net::HTTPBadResponse, 'wrong header line format' if value.nil?
    end
  end

  yield key, value if key
end

# HTTPHeader#add_field (lib/net/http/header.rb)

def add_field(key, val)
  stringified_downcased_key = key.downcase.to_s

  if @header.key?(stringified_downcased_key)
    append_field_value(@header[stringified_downcased_key], val) # => HTTPHeader#append_field_value
  else
    set_field(key, val) # => HTTPHeader#set_field
  end
end

# HTTPHeader#append_field_value (lib/net/http/header.rb)

def append_field_value(ary, val)
  case val
  when Enumerable
    val.each{ |x| append_field_value(ary, x) } # => HTTPHeader#append_field_value
  else
    val = val.to_s
    raise ArgumentError, 'header field value cannot include CR/LF' if /[\r\n]/n.match?(val.b)
    ary.push val
  end
end

# HTTPHeader#set_field (lib/net/http/header.rb)

def set_field(key, val)
  case val
  when Enumerable
    ary = []
    append_field_value(ary, val) # => HTTPHeader#append_field_value
    @header[key.downcase.to_s] = ary
  else
    val = val.to_s # for compatibility use to_s instead of to_str
    raise ArgumentError, 'header field value cannot include CR/LF' if val.b.count("\r\n") > 0
    @header[key.downcase.to_s] = [val]
  end
end

# HTTPResponse#reading_body (lib/net/http/response.rb)

def reading_body(sock, reqmethodallowbody)
  @socket = sock # ここで再代入しているのはensureで初期化するから?
  @body_exist = reqmethodallowbody && self.class.body_permitted?

  begin
    yield
    self.body # => HTTPResponse#body
  ensure
    @socket = nil
  end
end

# HTTPResponse#body (lib/net/http/response.rb)

def body
  read_body() # => HTTPResponse#read_body
end

# HTTPResponse#read_body (lib/net/http/response.rb)

def read_body(dest = nil, &block) # HTTPResponse#bodyから呼び出している場合、引数は空になる
  if @read
    raise IOError, "#{self.class}\#read_body called twice" if dest or block
    return @body
  end

  to = procdest(dest, block) # => HTTPResponse#procdest

  # HTTPResponse#procdest (lib/net/http/response.rb)
  #
  #   def procdest(dest, block)
  #     raise ArgumentError, 'both arg and block given for HTTP method' if dest and block
  #
  #     if block
  #       Net::ReadAdapter.new(block)
  #     else
  #       dest || +'' # # HTTPResponse#read_bodyから呼び出している場合は空文字を返す
  #     end
  #   end

  stream_check # => HTTPResponse#stream_check

  # HTTPResponse#stream_check (lib/net/http/response.rb)
  #
  #   def stream_check
  #     raise IOError, 'attempt to read body out of block' if @socket.nil? || @socket.closed?
  #   end

  if @body_exist
    read_body_0 to # => HTTPResponse#read_body_0
    @body = to
  else
    @body = nil
  end

  @read = true
  return if @body.nil?

  case enc = @body_encoding
  when Encoding, false, nil
    # Encoding: force given encoding
    # false/nil: do not force encoding
  else
    # other value: detect encoding from body
    enc = detect_encoding(@body) # => HTTPResponse#detect_encoding
  end

  @body.force_encoding(enc) if enc # => String#force_encoding
  @body
end

# HTTPResponse#read_body_0 (lib/net/http/response.rb)

def read_body_0(dest)
  inflater do |inflate_body_io| # => HTTPResponse#inflater
    if chunked?
      read_chunked dest, inflate_body_io # => HTTPResponse#read_chunked
      return
    end

    # inflate_body_ioは解凍されたHTTPResponse::Inflaterインスタンス、もしくはそのままのNet::BufferedIOインスタンス
    @socket = inflate_body_io
    clen = content_length() # => HTTPHeader#content_length

    if clen # Content-Lnegth分を読み取る
      @socket.read clen, dest, @ignore_eof  # => HTTPResponse::Inflater#read, Net::BufferedIO#read
      return
    end

    clen = range_length() # => HTTPHeader#range_length

    if clen # Range分を読み取る
      @socket.read clen, dest # => HTTPResponse::Inflater#read, Net::BufferedIO#read
      return
    end

    @socket.read_all dest # => HTTPResponse::Inflater#read_all, Net::BufferedIO#read_all
  end
end

# HTTPResponse#inflater (lib/net/http/response.rb)

# レスポンスボディの圧縮を解除しているっぽい
def inflater
  # zlibがないので圧縮を扱えない場合
  return yield @socket unless Net::HTTP::HAVE_ZLIB

  # 実行時に外部からヘッダが指定されていない、またはAccept-EncodingかRangeを設定していない場合
  return yield @socket unless @decode_content

  # HTTPGenericRequest#initialize (lib/net/http/generic_request.rb)
  #
  #   if Net::HTTP::HAVE_ZLIB
  #     if !initheader || !initheader.keys.any? { |k| %w[accept-encoding range].include? k.downcase }
  #       # ここでHTTPGenericRequestインスタンスが@decode_contentを保持し、
  #       @decode_content = true if @response_has_body
  #       initheader = initheader ? initheader.dup : {}
  #       initheader["accept-encoding"] = "gzip;q=1.0,deflate;q=0.6,identity;q=0.3"
  #     end
  #   end
  #
  # HTTPGenericRequest#wait_for_continue (lib/net/http/generic_request.rb)
  #
  #   if ver >= '1.1' and @header['expect'] and @header['expect'].include?('100-continue')
  #     if sock.io.to_io.wait_readable(sock.continue_timeout)
  #       res = Net::HTTPResponse.read_new(sock)
  #
  #       unless res.kind_of?(Net::HTTPContinue)
  #         # ここでHTTPResponseインスタンスのdecode_contentに書き戻す
  #         res.decode_content = @decode_content
  #         throw :response, res
  #       end
  #     end
  #   end
  #
  # この時点で@decode_contentがfalse (初期状態) になっているものはここで return yield @socket される

  # Content-Rangeレスポンスヘッダがある場合
  return yield @socket if self['content-range']

  v = self['content-encoding']

  # Content-Encodingレスポンスヘッダの値によって解凍したボディや何もしていないボディを利用して読み込み処理を進める
  case v&.downcase
  when 'deflate', 'gzip', 'x-gzip' then
    self.delete 'content-encoding'
    inflate_body_io = Inflater.new(@socket) # HTTPResponse::Inflater 圧縮されたストリームを逐次解凍するためのラッパ

    begin
      yield inflate_body_io
      success = true
    ensure
      begin
        inflate_body_io.finish
        if self['content-length']
          self['content-length'] = inflate_body_io.bytes_inflated.to_s
        end
      rescue => err
        # Ignore #finish's error if there is an exception from yield
        raise err if success
      end
    end
  when 'none', 'identity' then
    self.delete 'content-encoding'
    yield @socket
  else
    yield @socket
  end
end

# HTTPResponse#read_chunked (lib/net/http/response.rb)

def read_chunked(dest, chunk_data_io)
  total = 0

  while true
    line = @socket.readline
    hexlen = line.slice(/[0-9a-fA-F]+/) or raise Net::HTTPBadResponse, "wrong chunk size line: #{line}"
    len = hexlen.hex
    break if len == 0

    begin
      chunk_data_io.read len, dest
    ensure
      total += len
      @socket.read 2   # \r\n
    end
  end

  until @socket.readline.empty?
    # none
  end
end

# HTTPResponse#detect_encoding (lib/net/http/response.rb)

def detect_encoding(str, encoding=nil)
  if encoding
  elsif encoding = type_params['charset']
  elsif encoding = check_bom(str)
  else
    encoding = case content_type&.downcase
               when %r{text/x(?:ht)?ml|application/(?:[^+]+\+)?xml}
                 /\A<xml[ \t\r\n]+
                   version[ \t\r\n]*=[ \t\r\n]*(?:"[0-9.]+"|'[0-9.]*')[ \t\r\n]+
                   encoding[ \t\r\n]*=[ \t\r\n]*
                   (?:"([A-Za-z][\-A-Za-z0-9._]*)"|'([A-Za-z][\-A-Za-z0-9._]*)')/x =~ str
                 encoding = $1 || $2 || Encoding::UTF_8
               when %r{text/html.*}
                 sniff_encoding(str)
               end
  end

  return encoding
end

# HTTP#end_transport (lib/net/http.rb)

# 最後にソケットをクローズしたり、再利用のためのセットアップをしたりする
def end_transport(req, res)
  @curr_http_version = res.http_version
  @last_communicated = nil

  if @socket.closed?
    debug 'Conn socket closed'
  elsif not res.body and @close_on_empty_response
    debug 'Conn close'
    @socket.close
  elsif keep_alive?(req, res)
    debug 'Conn keep-alive'
    @last_communicated = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  else
    debug 'Conn close'
    @socket.close
  end
end
```

## `HTTPResponse::Inflater`

```ruby
# (lib/net/http/response.rb)

class Inflater
  def initialize(socket)
    @socket = socket # Net::BufferedIOインスタンス
    # zlib with automatic gzip detection
    @inflate = Zlib::Inflate.new(32 + Zlib::MAX_WBITS)
  end

  # HTTPResponse::Inflater#read (lib/net/http/response.rb)

  def read(clen, dest, ignore_eof = false)
    temp_dest = inflate_adapter(dest) # => HTTPResponse::Inflater#inflate_adapter

    @socket.read(clen, temp_dest, ignore_eof) # => Net::BufferedIO#read (lib/net/protocol.rb)
  end

  # HTTPResponse::Inflater#read_all (lib/net/http/response.rb)

  def read_all(dest)
    temp_dest = inflate_adapter(dest) # => HTTPResponse::Inflater#inflate_adapter

    @socket.read_all temp_dest # => Net::BufferedIO#read_all (lib/net/protocol.rb)
  end

  # HTTPResponse::Inflater#inflate_adapter (lib/net/http/response.rb)

  def inflate_adapter(dest) # destが空文字の可能性あり
    if dest.respond_to?(:set_encoding)
      dest.set_encoding(Encoding::ASCII_8BIT)
    elsif dest.respond_to?(:force_encoding)
      dest.force_encoding(Encoding::ASCII_8BIT)
    end

    block = proc do |compressed_chunk|
      @inflate.inflate(compressed_chunk) do |chunk| # => Zlib::Inflate#inflate 入力データを展開
        compressed_chunk.clear
        dest << chunk
      end
    end

    Net::ReadAdapter.new(block) # => Net::ReadAdapter#initialize (lib/net/protocol.rb)
  end
end
```

## `HTTP.post`

```ruby
# url    = URI("https://httpbin.org/post")
# data   = '{ "foo": "bar" }'
# header = { "Content-Type": "application/json" }
def HTTP.post(url, data, header = nil)
  start(url.hostname, url.port, :use_ssl => url.scheme == 'https' ) { |http|
    http.post(url, data, header) # getと返り値の型が違うのか...
  }
end

def post(path, data, initheader = nil, dest = nil, &block) # :yield: +body_segment+
  send_entity(path, data, initheader, dest, Post, &block)
end

# path       = URI("https://httpbin.org/post")
# data       = '{ "foo": "bar" }'
# initheader = { "Content-Type": "application/json" }
# dest       = nil
# type       = Post
def send_entity(path, data, initheader, dest, type, &block)
  res = nil

  request(type.new(path, initheader), data) {|r|
    r.read_body dest, &block
    res = r
  }

  res
end
```

### `HTTP.post_form`

```ruby
def HTTP.post_form(url, params)
  req = Post.new(url)
  req.form_data = params
  req.basic_auth url.user, url.password if url.user

  start(url.hostname, url.port, :use_ssl => url.scheme == 'https' ) {|http|
    http.request(req)
  }
end
```
