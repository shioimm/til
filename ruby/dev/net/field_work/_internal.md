# net-http 現地調査 (202509時点)
https://github.com/ruby/ruby/blob/master/lib/net/http.rb

## 全体の流れ
- `HTTP.get` public
  - `HTTP.get_response` public
    - `HTTP.start` / `HTTP#start` public
      - `HTTP#do_start`
        - `HTTP#connect`
    - `HTTP#request_get` public WIP
      - `HTTP#request` public
        - `HTTPGenericRequest#set_body_internal`
        - `HTTP#transport_request`
          - `HTTP#begin_transport`
            - `HTTPGenericRequest#update_uri`
          - `HTTPGenericRequest#exec`
          - `HTTPResponse.read_new`
          - `HTTPResponse#reading_body`
          = `HTTP#end_transport`

### 気づいたこと
- すでにresolvライブラリに依存している

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
    # => HTTP#initialize (lib/net/http.rb)
    # => HTTP#start (lib/net/http.rb)
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
```

## `HTTP.start`

```ruby
# (lib/net/http.rb)

def HTTP.start(address, *arg, &block) # :yield: +http+
  arg.pop if opt = Hash.try_convert(arg[-1])
  port, p_addr, p_port, p_user, p_pass = *arg
  p_addr = :ENV if arg.size < 2
  port = https_default_port if !port && opt && opt[:use_ssl]

  http = new(address, port, p_addr, p_port, p_user, p_pass)
  http.ipaddr = opt[:ipaddr] if opt && opt[:ipaddr]

  if opt
    if opt[:use_ssl]
      opt = {verify_mode: OpenSSL::SSL::VERIFY_PEER}.update(opt)
    end

    http.methods.grep(/\A(\w+)=\z/) do |meth|
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
    conn_addr = proxy_address
    conn_port = proxy_port
  else
    conn_addr = conn_address
    conn_port = port
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
        ssl_socket_connect(proxy_sock, @open_timeout) # このメソッドはどこに定義されているんだろう
      else
        proxy_sock = s
      end

      proxy_sock = BufferedIO.new(
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
    ssl_socket_connect(s, @open_timeout)

    if (@ssl_context.verify_mode != OpenSSL::SSL::VERIFY_NONE) && verify_hostname
      s.post_connection_check(@address)
    end

    debug "SSL established, protocol: #{s.ssl_version}, cipher: #{s.cipher[0]}"
  end
  # --- TLS接続ここまで ---

  @socket = BufferedIO.new(
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
  # => class Net::HTTPRequest

  # class Net::HTTPRequest (lib/net/http/request.rb)
  #   class Net::HTTPRequest < Net::HTTPGenericRequest
  #    def initialize(path, initheader = nil)
  #      super self.class::METHOD,
  #            self.class::REQUEST_HAS_BODY,
  #            self.class::RESPONSE_HAS_BODY,
  #            path, initheader
  #    end
  #  end
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

  # HTTPGenericRequest#set_body_internal (lib/net/http/generic_request.rb)
  #   def set_body_internal(str)
  #     raise ArgumentError, "both of body argument and HTTPRequest#body set" if str and (@body or @body_stream)
  #     # どういう状況?と思ったらHTTPGenericRequest#body=もしくは#body_stream=で値がセットされていることがあるらしい
  #     # 柔軟すぎでは????
  #
  #     self.body = str if str
  #
  #     if @body.nil? && @body_stream.nil? && @body_data.nil? && request_body_permitted?
  #       self.body = ''
  #     end
  #   end

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
    req['connection'] ||= 'close'
  end

  req.update_uri address, port, use_ssl? # => HTTPGenericRequest#update_uri
  req['host'] ||= addr_port()
end

# HTTPGenericRequest#update_uri (lib/net/http/generic_request.rb)

def update_uri(addr, port, ssl) # :nodoc: internal use only
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

# HTTPGenericRequest#exec (lib/net/http/generic_request.rb)

def exec(sock, ver, path)   #:nodoc: internal use only
  if @body
    send_request_with_body sock, ver, path, @body

    # Net::HTTPGenericRequest#send_request_with_body
    # def send_request_with_body(sock, ver, path, body)
    #   self.content_length = body.bytesize
    #   delete 'Transfer-Encoding'
    #   supply_default_content_type
    #
    #   write_header sock, ver, path
    #   wait_for_continue sock, ver if sock.continue_timeout
    #   sock.write body
    # end

  elsif @body_stream
    send_request_with_body_stream sock, ver, path, @body_stream
  elsif @body_data
    send_request_with_body_data sock, ver, path, @body_data
  else
    write_header sock, ver, path

    # Net::HTTPGenericRequest#write_header
    # def write_header(sock, ver, path)
    #   reqline = "#{@method} #{path} HTTP/#{ver}"
    #
    #   if /[\r\n]/ =~ reqline
    #     raise ArgumentError, "A Request-Line must not contain CR or LF"
    #   end
    #
    #   buf = +''
    #   buf << reqline << "\r\n"
    #
    #   each_capitalized do |k,v|
    #     buf << "#{k}: #{v}\r\n"
    #   end
    #
    #   buf << "\r\n"
    #   sock.write buf
    # end
  end
end

# HTTPResponse.read_new (lib/net/http/response.rb)

def read_new(sock)   #:nodoc: internal use only
  httpv, code, msg = read_status_line(sock)

  # HTTPResponse.read_status_line
  # def read_status_line(sock)
  #   str = sock.readline
  #   m = /\AHTTP(?:\/(\d+\.\d+))?\s+(\d\d\d)(?:\s+(.*))?\z/in.match(str) or
  #     raise Net::HTTPBadResponse, "wrong status line: #{str.dump}"
  #   m.captures
  # end

  # ここでレスポンスステータスごとにクラスが分かれてしまっている
  res = response_class(code).new(httpv, code, msg)

  # HTTPResponse.response_class
  # def response_class(code)
  #   CODE_TO_OBJ[code] or            # Net::HTTPResponse::CODE_TO_OBJとして定義されている
  #   CODE_CLASS_TO_OBJ[code[0,1]] or # Net::HTTPResponse::CODE_CLASS_TO_OBJとして定義されている
  #   Net::HTTPUnknownResponse
  # end

  each_response_header(sock) do |k,v|
    res.add_field k, v
  end

  res
end

# HTTPResponse#reading_body (lib/net/http/response.rb)

def reading_body(sock, reqmethodallowbody)  #:nodoc: internal use only
  @socket = sock
  @body_exist = reqmethodallowbody && self.class.body_permitted?
  begin
    yield
    self.body   # ensure to read body
  ensure
    @socket = nil
  end
end

# HTTP#end_transport (lib/net/http.rb)

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

### `HTTP.post`

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

---

### わかったこと
- `Net::HTTP#start` -> `Net::HTTP#do_start` -> `Net::HTTP#connect`で接続を行う
- `Net::HTTP#do_start`実行後に`Net::HTTP#request`を呼び出す
  - `Net::HTTP#request`にHTTPメソッドを表すクラスのオブジェクトを渡す
  - `Net::HTTP#request` -> `Net::HTTP#transport_request` -> HTTPメソッドを表すオブジェクトに対して`#exec`
- 基本的にはHTTPステータスを表すクラスのオブジェクトが返り値になる (`Net::HTTP.get`以外)
- 毎リクエストごとに接続し、書き込みを行う
