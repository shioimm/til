# net-http 現地調査 (net-http-0.9.1時点)

以下の条件を満たすと例外が発生

- `HTTP::Response#read_body`にブロックを渡す
- `HTTP::Response#body_encoding=`を呼び出す

```ruby
uri = URI.parse("http://google.com")
http = Net::HTTP.new(uri.host, uri.port)
req = Net::HTTP::Get.new(uri)

http.request(req) do |response|
  # レスポンスのサイズが大きい or 不明なのでチャンクで読み取りたい
  # かつ最終的な結果も欲しい
  # かつテキストとして正しく扱いたい (nokogiriに渡したいなど) 場合など

  response.body_encoding = true
  body = +""
  response.read_body { |chunk| body << chunk }

  # => HTTP::Response#read_bodyのブロックを抜ける際に例外が発生する
  # undefined method 'force_encoding' for an instance of Net::ReadAdapter (NoMethodError)
end
```

```ruby
# この場合は発生しない
res = http.request(req)
res.body_encoding = true
res.body
```

## 話の流れ
- Feature #2567
  - `Content-Type`に指定されたcharsetから自動的にレスポンスボディを`force_encoding`しない
- Feature #15517
  - ユーザーが明示的に`force_encoding`を適用できるAPIを用意する
    - `HTTP#response_body_encoding=`
    - `HTTPResponse#body_encoding=`
- Feature #21773
  - Feature #15517はレスポンスボディがStringであることを前提にしている
  - 一方、`HTTPResponse#read_body`ではブロックを渡すとレスポンスボディReadAdapterとして扱うことになる
  - なのでユーザーが明示的に`force_encoding`を適用しようとするとReadAdapterに`force_encoding`を適用できずエラー
  - レスポンスボディをチャンクで処理しつつ、最終的なレスポンスボディに対して`force_encoding`を適用したい

## `HTTPResponse#body_encoding=`のセット
### `HTTPResponse`の初期化時

```ruby
# HTTPResponse#initialize (lib/net/http/response.rb)

def initialize(httpv, code, msg)   #:nodoc: internal use only
  @http_version = httpv
  @code         = code
  @message      = msg
  initialize_http_header nil
  @body = nil
  @read = false
  @uri  = nil
  @decode_content = false
  @body_encoding = false # 初期値はfalse
  @ignore_eof = true
end
```

### `HTTPResponse`に対して明示的にセットする

```ruby
# HTTPResponse#body_encoding= (lib/net/http/response.rb)

def body_encoding=(value) # コードの内容はHTTP#response_body_encoding=と同じ
  if value.is_a?(String)
    value = Encoding.find(value)
    # => Encoding.find 指定された名前を持つEncodingオブジェクトを返す
  end

  @body_encoding = value
end
```

### 外部から指定された値を`HTTP#request` -> `HTTP#transport_request`でセットし直す

```ruby
# HTTP#initialize ()

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

  # Net::HTTP.default_configurationとして初期設定を持つ
  options = defaults.merge(self.class.default_configuration || {})

  # ...
  @response_body_encoding = options[:response_body_encoding]
  #...
end

# HTTP#response_body_encoding= (lib/net/http.rb)

def response_body_encoding=(value) # コードの内容はHTTPResponse#body_encoding=と同じ
  value = Encoding.find(value) if value.is_a?(String)
  @response_body_encoding = value
end

# HTTP#transport_request (lib/net/http.rb)

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
        res = HTTPResponse.read_new(@socket) # => HTTPResponse.read_new レスポンスそのものの取得
        res.decode_content = req.decode_content
        res.body_encoding = @response_body_encoding # => HTTPResponse#body_encoding= エンコーディングのセット
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

  end_transport req, res
  res
rescue => exception
  debug "Conn close because of error #{exception}"
  @socket.close if @socket
  raise exception
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
```

## レスポンスボディを読み出す仕組み
### `HTTPResponse`に対して明示的に`#read_body`を呼び出す

```ruby
# Net::HTTPResponse#read_body (lib/net/http/response.rb)

# WIP
def read_body(dest = nil, &block)
  if @read
    raise IOError, "#{self.class}\#read_body called twice" if dest or block
    return @body
  end

  to = procdest(dest, block) # => HTTPResponse#procdest ブロックを渡している場合はto = #<ReadAdapter>
  stream_check # => HTTPResponse#stream_check

  # HTTPResponse#stream_check (lib/net/http/response.rb)
  #
  #   def stream_check
  #     raise IOError, 'attempt to read body out of block' if @socket.nil? || @socket.closed?
  #   end

  if @body_exist # 前段でHTTPResponse#reading_bodyが呼ばれている場合はtrue / falseがセットされている
    read_body_0(to) # => HTTPResponse#read_body_0
    @body = to # ブロックを渡している場合はto = #<ReadAdapter>
  else
    @body = nil
  end

  @read = true
  return if @body.nil?

  case enc = @body_encoding # ユーザーが明示的にセットした値
  when Encoding, false, nil
    # Encoding: force given encoding
    # false/nil: do not force encoding
  else
    # other value: detect encoding from body
    enc = detect_encoding(@body) # => HTTPResponse#detect_encoding 暗黙的なエンコーディング情報
  end

  @body.force_encoding(enc) if enc

  @body
end

# https://github.com/ruby/net-http/commit/6233e6b7c1f7bb8a667b5781ec43ff8c09c84268
# 変更が入る前のHTTPResponse#read_body
#
#   def read_body(dest = nil, &block)
#     if @read
#       raise IOError, "#{self.class}\#read_body called twice" if dest or block
#       return @body
#     end
#
#     to = procdest(dest, block)
#     stream_check

#     if @body_exist
#       read_body_0 to
#       @body = to
#     else
#       @body = nil
#     end
#
#     @read = true # 変更後はこの行が消えた
#
#     # <変更後はここで@body.force_encodingしている>
#
#     @body
#   end

# Net::HTTPResponse#procdest (lib/net/http/response.rb)

def procdest(dest, block)
  raise ArgumentError, 'both arg and block given for HTTP method' if dest and block

  if block
    Net::ReadAdapter.new(block) # => Net::ReadAdapter#initialize

    # ReadAdapter#initialize (net-protocol: lib/net/protocol.rb)
    #
    #   def initialize(block)
    #     @block = block
    #   end
  else
    dest || +''
  end
end

# HTTPResponse#detect_encoding (lib/net/http/response.rb)

def detect_encoding(str, encoding=nil)
  if encoding
  elsif encoding = type_params['charset']
  elsif encoding = check_bom(str) # => HTTPResponse#check_bom
  else
    encoding = case content_type&.downcase

    when %r{text/x(?:ht)?ml|application/(?:[^+]+\+)?xml}
      /\A<xml[ \t\r\n]+
        version[ \t\r\n]*=[ \t\r\n]*(?:"[0-9.]+"|'[0-9.]*')[ \t\r\n]+
        encoding[ \t\r\n]*=[ \t\r\n]*
        (?:"([A-Za-z][\-A-Za-z0-9._]*)"|'([A-Za-z][\-A-Za-z0-9._]*)')/x =~ str
      encoding = $1 || $2 || Encoding::UTF_8
    when %r{text/html.*}
      sniff_encoding(str) # => HTTPResponse#sniff_encoding
    end
  end

  return encoding
end

# HTTPResponse#check_bom (lib/net/http/response.rb)

def check_bom(str)
  case str.byteslice(0, 2)
  when "\xFE\xFF"
    return Encoding::UTF_16BE
  when "\xFF\xFE"
    return Encoding::UTF_16LE
  end
  if "\xEF\xBB\xBF" == str.byteslice(0, 3)
    return Encoding::UTF_8
  end
  nil
end

# HTTPResponse#sniff_encoding (lib/net/http/response.rb)

def sniff_encoding(str, encoding=nil)
  # the encoding sniffing algorithm
  # http://www.w3.org/TR/html5/parsing.html#determining-the-character-encoding
  if enc = scanning_meta(str) # => HTTPResponse#scanning_meta
    enc
  # 6. last visited page or something
  # 7. frequency
  elsif str.ascii_only?
    Encoding::US_ASCII
  elsif str.dup.force_encoding(Encoding::UTF_8).valid_encoding?
    Encoding::UTF_8
  end
  # 8. implementation-defined or user-specified
end

# HTTPResponse#scanning_meta (lib/net/http/response.rb)

def scanning_meta(str)
  require 'strscan'

  ss = StringScanner.new(str)

  if ss.scan_until(/<meta[\t\n\f\r ]*/)
    attrs = {} # attribute_list
    got_pragma = false
    need_pragma = nil
    charset = nil

    # step: Attributes
    while attr = get_attribute(ss)
      name, value = *attr
      next if attrs[name]
      attrs[name] = true
      case name
      when 'http-equiv'
        got_pragma = true if value == 'content-type'
      when 'content'
        encoding = extracting_encodings_from_meta_elements(value)
        unless charset
          charset = encoding
        end
        need_pragma = true
      when 'charset'
        need_pragma = false
        charset = value
      end
    end

    # step: Processing
    return if need_pragma.nil?
    return if need_pragma && !got_pragma

    charset = Encoding.find(charset) rescue nil
    return unless charset
    charset = Encoding::UTF_8 if charset == Encoding::UTF_16
    return charset # tentative
  end
  nil
end
```

### `HTTP#request`で読み出す
- `HTTP#request` -> `HTTP#transport_request` -> `HTTPResponse#reading_body` -> `HTTPResponse#read_body`

```ruby
# HTTPResponse#reading_body (lib/net/http/response.rb)

def reading_body(sock, reqmethodallowbody)
  @socket = sock
  @body_exist = reqmethodallowbody && self.class.body_permitted? # => HTTPResponse.body_permitted

  begin
    yield
    self.body # => HTTPResponse#body
  ensure
    @socket = nil
  end
end

# HTTPResponse.body_permitted (lib/net/http/response.rb)

def body_permitted?
  self::HAS_BODY # 各レスポンスを表す子クラスが持っている情報
end
```
