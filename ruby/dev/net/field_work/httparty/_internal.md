# httparty 現地調査 (202511時点)

## 全体の流れ
- `HTTParty.get` public
  - `HTTParty.perform_request`
    - `HTTParty.build_request` public
      - `ModuleInheritableAttributes.hash_deep_dup`
      - `HeadersProcessor#initialize`
      - `HeadersProcessor#call`
      - `HTTParty.process_cookies`
      - `Request#initialize`
        - `Request#http_method=`
        - `Request#options=`
        - `Request#path=`
        - `Request#set_basic_auth_from_uri`
    - `Request#perform`
      - `Request#validate`
      - `Request#setup_raw_request`
        - `Net::HTTP::{リクエストを表すクラス}`
        - `Request::Body#initialize`
        - `Request::Body#call`
      - `Request#http`
        - `Request#connection_adapter`
        - `ConnectionAdapter.call`
          - `ConnectionAdapter#connection`
            - `Net::HTTP.new`
            - `ConnectionAdapter#ssl_implied?`
            - `ConnectionAdapter#attach_ssl_certificates`
      - `#<Net::HTTP>#request(@raw_request)`
      - `Request#handle_host_redirection`
      - `Request#handle_unauthorized`
      - `Request#handle_response`
        - (リダイレクト時)
          - `Request#handle_redirection`
            - `Request#capture_cookies`
        - (非リダイレクト時)
          - (ボディがある場合) `Request#decompress`
            - `Decompressor#decompress_supported_encoding`
              - `Decompressor#{圧縮方式に応じて解凍}`
          - (ボディがある場合) `Request#encode_text`)
            - `TextEncoder#call`
              - `TextEncoder#encoded_text`
          - `Request#parse_response`
            - `Parser.call`
              - `Parser#parse`
                - `Parser#parse_supported_format`
                  - `Parser#{Content-Typeに応じてパース}`
          - `Response#initialize`
            - `Response::Headers#initialize`

### 気づいたこと
- net-httpに実装を移譲しているところが結構ある。使い勝手を良くしたラッパーという感じ
- faradayやhttpxのようにアダプタを差し替えたりはできないっぽい

#### 追加機能
- TLSの設定 (`ConnectionAdapter#attach_ssl_certificates`)
- タイムアウトの設定 (`ConnectionAdapter#connection`)
- プロキシの設定 (`ConnectionAdapter#connection`)
- ストリームレスポンス (`Request#perform`)
- brotli / lzw / zstdなどnet-httpがサポートしていない圧縮形式でも自動解凍できる (`Decompressor`)
- Content-TypeのcharsetをもとにRubyでのエンコーディングを実施する (`TextEncoder`)
- 自動リダイレクトさせる (デフォルトでは5回が上限) (`Request#handle_redirection`)
  - 303、301、302の場合はGETへ変換
  - 307、308の場合はリクエストメソッドを維持
- リダイレクト先のドメインが変わったかどうかを保持する (`Request#handle_host_redirection`)
- Digest認証にて401 Unauthorizedを自動で再送する (`Request#handle_unauthorized`)
- Cookieを管理する
  - リクエストヘッダにCookieをセットする (`HTTParty.process_cookies`)
  - レスポンスヘッダからSet-Cookieを取得し、次のリクエストに含める (`Request#capture_cookies`)
- レスポンスボディをパースして扱いやすくする (`HTTParty::Parser` / `Response#parsed_response`)
- レスポンスヘッダで複数値を扱いやすくする (`Response::Headers`)

## `HTTParty.get`

```ruby
# (lib/httparty.rb)

def self.included(base)
  base.extend ClassMethods
  base.send :include, ModuleInheritableAttributes
  base.send(:mattr_inheritable, :default_options)
  base.send(:mattr_inheritable, :default_cookies)
  base.instance_variable_set(:@default_options, {})
  base.instance_variable_set(:@default_cookies, CookieHash.new)
end

# HTTParty.get (lib/httparty.rb)

def get(path, options = {}, &block)
  perform_request(Net::HTTP::Get, path, options, &block)
  # net-httpではHTTP#request_getにてHTTP::Get.newの返り値としてNet::HTTP::Getオブジェクトを得ている
  # => HTTParty.perform_request
end

# HTTParty.perform_request (lib/httparty.rb)

def perform_request(http_method, path, options, &block) #:nodoc:
  build_request(http_method, path, options).perform(&block)
  # => HTTParty.build_request
  # => Request#perform
end

# HTTParty.build_request  (lib/httparty.rb)

def build_request(http_method, path, options = {})
  options = ModuleInheritableAttributes.hash_deep_dup(default_options).merge(options)
  # => ModuleInheritableAttributes.hash_deep_dup
  # default_options (Hash) を複製 (値も)
  # default_optionsはHTTPartyクラスのattribute

  HeadersProcessor.new(headers, options).call
  # => HeadersProcessor#initialize
  # => HeadersProcessor#call

  # HeadersProcessor#initialize (lib/httparty/headers_processor.rb)
  #
  #   def initialize(headers, options)
  #     @headers = headers
  #     @options = options
  #   end
  #
  # HeadersProcessor#call (lib/httparty/headers_processor.rb)
  #
  #   def call
  #     return unless options[:headers]
  #     options[:headers] = headers.merge(options[:headers]) if headers.any?
  #     options[:headers] = Utils.stringify_keys(process_dynamic_headers)
  #   end

  process_cookies(options) # => HTTParty.process_cookies

  Request.new(http_method, path, options) # => Request#initialize
end

# HTTParty.process_cookies (lib/httparty.rb)

def process_cookies(options) #:nodoc:
  return unless options[:cookies] || default_cookies.any?

  options[:headers] ||= headers.dup
  options[:headers]['cookie'] = cookies.merge(options.delete(:cookies) || {}).to_cookie_string
end

# Request#initialize (lib/httparty/request.rb)

def initialize(http_method, path, o = {})
  @changed_hosts = false
  @credentials_sent = false

  self.http_method = http_method
  self.options = {
    limit: o.delete(:no_follow) ? 1 : 5,
    assume_utf16_is_big_endian: true,
    default_params: {},
    follow_redirects: true,
    parser: Parser, # HTTParty::Parser
    uri_adapter: URI,
    connection_adapter: ConnectionAdapter # HTTParty::ConnectionAdapter
  }.merge(o)
  self.path = path

  set_basic_auth_from_uri # => Request#set_basic_auth_from_uri
end

# Request#set_basic_auth_from_uri (lib/httparty/request.rb)

def set_basic_auth_from_uri
  if path.userinfo
    username, password = path.userinfo.split(':')
    options[:basic_auth] = {username: username, password: password}
    @credentials_sent = true
  end
end

# Request#perform (lib/httparty/request.rb)

def perform(&block)
  validate # => Request#validate
  setup_raw_request # => Request#setup_raw_request

  # @raw_request = #<Net::HTTP::Get GET
  #                  @body=nil
  #                  @body_data=nil
  #                  @body_stream=nil
  #                  @decode_content=true
  #                  @header={
  #                    "accept-encoding" => ["gzip;q=1.0,deflate;q=0.6,identity;q=0.3"],
  #                    "accept" => ["*/*"],
  #                    "user-agent" => ["Ruby"]
  #                  }
  #                  @method="GET"
  #                  @path="/"
  #                  @request_has_body=false
  #                  @response_has_body=true
  #                  @uri=nil>

  chunked_body = nil
  current_http = http # => Request#http
  # current_http = #<Net::HTTP>

  # self.last_response = #<Net::HTTP>#request(@raw_request)
  self.last_response = current_http.request(@raw_request) do |http_response|
    if block
      chunks = []

      http_response.read_body do |fragment|
        encoded_fragment = encode_text(fragment, http_response['content-type']) # => Request#encode_text
        chunks << encoded_fragment if !options[:stream_body]
        block.call(ResponseFragment.new(encoded_fragment, http_response, current_http))
      end

      chunked_body = chunks.join
    end
  end
  # => self.last_response = #<Net::HTTPOK 200 OK readbody=true> など

  handle_host_redirection if response_redirects?
  # => Request#response_redirects レスポンスがリダイレクトかどうか
  # => Request#handle_host_redirection リダイレクト後のドメインが変わったかどうかを@changed_hostsに記録

  result = handle_unauthorized # => Request#handle_unauthorized レスポンスが401 Unauthorizedの場合Digest認証を再送
  result ||= handle_response(chunked_body, &block) # => Request#handle_response
  result # #<Request> を返す
end

# Request#validate (lib/httparty/request.rb)

def validate
  # リダイレクト回数が上限を超えていないか
  if options[:limit].to_i <= 0
    raise HTTParty::RedirectionTooDeep.new(last_response), 'HTTP redirects too deep'
  end

  # 許可されたHTTP メソッドか
  unless SupportedHTTPMethods.include?(http_method)
    raise ArgumentError, 'only get, post, patch, put, delete, head, and options methods are supported'
  end

  # headersはto_hash可能か (Hashにしたい)
  if options[:headers] && !options[:headers].respond_to?(:to_hash)
    raise ArgumentError, ':headers must be a hash'
  end

  # Basic認証とDigest認証が併用されていないか
  if options[:basic_auth] && options[:digest_auth]
    raise ArgumentError, 'only one authentication method, :basic_auth or :digest_auth may be used at a time'
  end

  # basic_authはto_hash可能か (Hashにしたい)
  if options[:basic_auth] && !options[:basic_auth].respond_to?(:to_hash)
    raise ArgumentError, ':basic_auth must be a hash'
  end

  # digest_authはto_hash可能か (Hashにしたい)
  if options[:digest_auth] && !options[:digest_auth].respond_to?(:to_hash)
    raise ArgumentError, ':digest_auth must be a hash'
  end

  # POSTリクエストの場合、queryはto_hash可能か (Hashにしたい)
  if post? && !options[:query].nil? && !options[:query].respond_to?(:to_hash)
    raise ArgumentError, ':query must be hash if using HTTP Post'
  end
end

# Request#setup_raw_request (lib/httparty/request.rb)

def setup_raw_request
  if options[:headers].respond_to?(:to_hash)
    headers_hash = options[:headers].to_hash
  else
    headers_hash = nil
  end

  # http_method = self.http_method (Net::HTTP::{リクエストを表すクラス})
  # uri         = #<URI::HTTPS> など => Request#uri
  @raw_request = http_method.new(request_uri(uri), headers_hash) # => Request#request_uri

  # Request#request_uri (lib/httparty/request.rb)
  #
  #   def request_uri(uri)
  #     uri.respond_to?(:request_uri) ? uri.request_uri : uri.path
  #   end

  # なので例えば @raw_request = Net::HTTP::Get.new("/", nil) のようになる

  @raw_request.body_stream = options[:body_stream] if options[:body_stream]

  if options[:body]
    body = Body.new( # => Request::Body#initialize
      options[:body],
      query_string_normalizer: query_string_normalizer,
      force_multipart: options[:multipart]
    )

    if body.multipart?
      content_type = "multipart/form-data; boundary=#{body.boundary}"
      @raw_request['Content-Type'] = content_type
    end

    @raw_request.body = body.call # => Request::Body#call
  end

  @raw_request.instance_variable_set(:@decode_content, decompress_content?)
  # !options[:skip_decompression] => Request#decompress_content?

  # Basic認証あり、かつリダイレクト時にホストが変更されている
  if options[:basic_auth] && send_authorization_header? # => Request#send_authorization_header?
    @raw_request.basic_auth(username, password)
    @credentials_sent = true
  end

  if digest_auth? && response_unauthorized? && response_has_digest_auth_challenge?
    setup_digest_auth # => Request#setup_digest_auth
  end
end

# Request::Body#initialize (lib/httparty/request/body.rb)

def initialize(params, query_string_normalizer: nil, force_multipart: false)
  @params = params
  @query_string_normalizer = query_string_normalizer
  @force_multipart = force_multipart
end

# Request::Body#call (lib/httparty/request/body.rb)

def call
  if params.respond_to?(:to_hash)
    multipart? ? generate_multipart : normalize_query(params)
  else
    params
  end
end

# Request#http (lib/httparty/request/body.rb)

def http
  connection_adapter.call(uri, options)
  # => Request#connection_adapter
  # => ConnectionAdapter.call

  # Request#connection_adapter (lib/httparty/request/body.rb)
  #
  #   def connection_adapter
  #     options[:connection_adapter] # デフォルトではConnectionAdapter
  #   end
end

# ConnectionAdapter.call (lib/httparty/connection_adapter.rb)

def self.call(uri, options)
  new(uri, options).connection
  # => ConnectionAdapter#initialize
  # => ConnectionAdapter#connection
end

# ConnectionAdapter#initialize (lib/httparty/connection_adapter.rb)

def initialize(uri, options = {})
  uri_adapter = options[:uri_adapter] || URI
  raise ArgumentError, "uri must be a #{uri_adapter}, not a #{uri.class}" unless uri.is_a? uri_adapter

  @uri = uri
  @options = OPTION_DEFAULTS.merge(options)
end

# ConnectionAdapter#connection (lib/httparty/connection_adapter.rb)

def connection
  host = clean_host(uri.host) # StripIpv6BracketsRegex =~ host ? $1 : host => ConnectionAdapter#strip_ipv6_brackets
  port = uri.port || (uri.scheme == 'https' ? 443 : 80)

  if options.key?(:http_proxyaddr)
    http = Net::HTTP.new(
      host,
      port,
      options[:http_proxyaddr],
      options[:http_proxyport],
      options[:http_proxyuser],
      options[:http_proxypass]
    )
  else
    http = Net::HTTP.new(host, port)
  end

  http.use_ssl = ssl_implied?(uri) # uri.port == 443 || uri.scheme == 'https' => ConnectionAdapter#ssl_implied?

  if http.use_ssl?
    # httpに対してTLSの設定を行う
    attach_ssl_certificates(http, options) # => ConnectionAdapter#attach_ssl_certificates
  end

  if add_timeout?(options[:timeout])
    http.open_timeout = options[:timeout]
    http.read_timeout = options[:timeout]
    http.write_timeout = options[:timeout]
  end

  if add_timeout?(options[:read_timeout])
    http.read_timeout = options[:read_timeout]
  end

  if add_timeout?(options[:open_timeout])
    http.open_timeout = options[:open_timeout]
  end

  if add_timeout?(options[:write_timeout])
    http.write_timeout = options[:write_timeout]
  end

  if add_max_retries?(options[:max_retries])
    http.max_retries = options[:max_retries]
  end

  if options[:debug_output]
    http.set_debug_output(options[:debug_output])
  end

  if options[:ciphers]
    http.ciphers = options[:ciphers]
  end

  # Bind to a specific local address or port
  #
  # @see https://bugs.ruby-lang.org/issues/6617
  if options[:local_host]
    http.local_host = options[:local_host]
  end

  if options[:local_port]
    http.local_port = options[:local_port]
  end

  http # => #<Net::HTTP>
end

# ConnectionAdapter#attach_ssl_certificates (lib/httparty/connection_adapter.rb)

def attach_ssl_certificates(http, options)
  if options.fetch(:verify, true)
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    if options[:cert_store]
      http.cert_store = options[:cert_store]
    else
      # Use the default cert store by default, i.e. system ca certs
      http.cert_store = self.class.default_cert_store
    end
  else
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end

  # Client certificate authentication
  # Note: options[:pem] must contain the content of a PEM file having the private key appended
  if options[:pem]
    http.cert = OpenSSL::X509::Certificate.new(options[:pem])
    http.key = OpenSSL::PKey.read(options[:pem], options[:pem_password])
    http.verify_mode = verify_ssl_certificate? ? OpenSSL::SSL::VERIFY_PEER : OpenSSL::SSL::VERIFY_NONE
  end

  # PKCS12 client certificate authentication
  if options[:p12]
    p12 = OpenSSL::PKCS12.new(options[:p12], options[:p12_password])
    http.cert = p12.certificate
    http.key = p12.key
    http.verify_mode = verify_ssl_certificate? ? OpenSSL::SSL::VERIFY_PEER : OpenSSL::SSL::VERIFY_NONE
  end

  # SSL certificate authority file and/or directory
  if options[:ssl_ca_file]
    http.ca_file = options[:ssl_ca_file]
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
  end

  if options[:ssl_ca_path]
    http.ca_path = options[:ssl_ca_path]
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
  end

  # This is only Ruby 1.9+
  if options[:ssl_version] && http.respond_to?(:ssl_version=)
    http.ssl_version = options[:ssl_version]
  end
end

# Request#response_redirects? (lib/httparty/request.rb)

def response_redirects?
  case last_response # self.last_response
  when Net::HTTPNotModified # 304
    false
  when Net::HTTPRedirection
    options[:follow_redirects] && last_response.key?('location')
  end
end

# Request#handle_host_redirection (lib/httparty/request.rb)

def handle_host_redirection
  check_duplicate_location_header
  redirect_path = options[:uri_adapter].parse(last_response['location']).normalize
  return if redirect_path.relative? || path.host == redirect_path.host || uri.host == redirect_path.host

  @changed_hosts = true

  # @changed_hostsはRequest#send_authorization_header?で利用される
  #
  # Request#send_authorization_header?
  #
  #   def send_authorization_header?
  #     !@changed_hosts
  #   end
end

# Request#handle_unauthorized (lib/httparty/request.rb)

def handle_unauthorized(&block)
  return unless digest_auth? && response_unauthorized? && response_has_digest_auth_challenge?
  return if @credentials_sent

  @credentials_sent = true
  perform(&block) # => Request#perform 401 Unauthorizedの場合もう一回実行
end

# Request#handle_response (lib/httparty/request.rb)

def handle_response(raw_body, &block)
  if response_redirects? # => Request#response_redirects?
    handle_redirection(&block) # => Request#handle_redirection
  else
    raw_body ||= last_response.body

    unless raw_body.nil?
      body = decompress(raw_body, last_response['content-encoding']) # => Request#decompress

      # Request#decompress (lib/httparty/request.rb)
      #
      # def decompress(body, encoding)
      #   Decompressor.new(body, encoding).decompress
      #   # => Decompressor#initialize
      #   # => Decompressor#decompress
      # end
    end

    unless body.nil?
      # Content-TypeをもとにRubyの文字エンコーディングを正しく設定する
      body = encode_text(body, last_response['content-type']) # => Request#encode_text

      if decompress_content? # !options[:skip_decompression] => Request#decompress_content?
        last_response.delete('content-encoding')
        raw_body = body
      end
    end

    Response.new(self, last_response, lambda { parse_response(body) }, body: raw_body)
    # => Request#parse_response
    # => Response#initialize
  end
end

# Request#handle_redirection (lib/httparty/request.rb)

def handle_redirection(&block)
  options[:limit] -= 1 # デフォルトは5

  if options[:logger]
    logger = HTTParty::Logger.build(options[:logger], options[:log_level], options[:log_format])
    logger.format(self, last_response)
  end

  self.path     = last_response['location'] # 次のリクエスト先をセット
  self.redirect = true

  if last_response.class == Net::HTTPSeeOther
    # 303 See Otherの場合
    unless options[:maintain_method_across_redirects] && options[:resend_on_redirect]
      self.http_method = Net::HTTP::Get # GETに変更
    end
  elsif last_response.code != '307' && last_response.code != '308'
    # 307 Temporary Redirect / 308 Permanent Redirect以外の場合
    unless options[:maintain_method_across_redirects]
      self.http_method = Net::HTTP::Get # GETに変更
    end
  end

  clear_body if http_method == Net::HTTP::Get # => Request#clear_body

  # Request#clear_body (lib/httparty/request.rb)
  #
  #   def clear_body
  #     options[:body] = nil
  #     @raw_request.body = nil
  #   end

  # Set-CookieをパースしてCookie ヘッダを再構築する
  capture_cookies(last_response) # => Request#capture_cookies

  perform(&block) # => Request#perform リダイレクトの場合もう一回実行
end

# Request#capture_cookies (lib/httparty/request.rb)

def capture_cookies(response)
  return unless response['Set-Cookie']
  cookies_hash = HTTParty::CookieHash.new

  if options[:headers] && options[:headers].to_hash['Cookie']
    cookies_hash.add_cookies(options[:headers].to_hash['Cookie'])
  end

  response.get_fields('Set-Cookie').each { |cookie| cookies_hash.add_cookies(cookie) }
  options[:headers] ||= {}
  options[:headers]['Cookie'] = cookies_hash.to_cookie_string
end

# Decompressor#initialize (lib/httparty/decompressor.rb)

attr_reader :encoding

def initialize(body, encoding)
  @body = body
  @encoding = encoding
end

# Decompressor#decompress (lib/httparty/decompressor.rb)

def decompress
  return nil if body.nil?
  return body if encoding.nil? || encoding.strip.empty?

  if supports_encoding?
    decompress_supported_encoding # => Decompressor#decompress_supported_encoding
  else
    nil
  end
end

# Decompressor#decompress_supported_encoding (lib/httparty/decompressor.rb)

SupportedEncodings = {
  'none'     => :none,
  'identity' => :none,
  'br'       => :brotli,
  'compress' => :lzw,
  'zstd'     => :zstd
}.freeze

def decompress_supported_encoding
  method = SupportedEncodings[encoding]

  if respond_to?(method, true)
    send(method)
  else
    raise NotImplementedError,
          "#{self.class.name} has not implemented a decompression method for #{encoding.inspect} encoding."
  end
end

# Request#encode_text (lib/httparty/request.rb)

def encode_text(text, content_type)
  TextEncoder.new(
    text,
    content_type: content_type,
    assume_utf16_is_big_endian: assume_utf16_is_big_endian # デフォルトではtrue
  ).call
  # => TextEncoder#initialize
  # => TextEncoder#call
end

# TextEncoder#initialize (lib/httparty/text_encoder.rb)

def initialize(text, assume_utf16_is_big_endian: true, content_type: nil)
  @text = +text # force_encoding時に元のtextを壊さないように複製
  @content_type = content_type
  @assume_utf16_is_big_endian = assume_utf16_is_big_endian
end

# TextEncoder#call (lib/httparty/text_encoder.rb)

def call
  if can_encode? # ''.respond_to?(:encoding) && charset => TextEncoder#can_encode?
    encoded_text # => TextEncoder#encoded_text
  else
    text
  end
end

# TextEncoder#encoded_text (lib/httparty/text_encoder.rb)

def encoded_text
  if 'utf-16'.casecmp(charset) == 0 # => TextEncoder#charset
    encode_utf_16 # => TextEncoder#encode_utf_16
  else
    encode_with_ruby_encoding # => TextEncoder#encode_with_ruby_encoding
  end
end

# TextEncoder#encode_utf_16 (lib/httparty/text_encoder.rb)

def encode_utf_16
  if text.bytesize >= 2
    if text.getbyte(0) == 0xFF && text.getbyte(1) == 0xFE
      return text.force_encoding('UTF-16LE')
    elsif text.getbyte(0) == 0xFE && text.getbyte(1) == 0xFF
      return text.force_encoding('UTF-16BE')
    end
  end

  if assume_utf16_is_big_endian # option
    text.force_encoding('UTF-16BE')
  else
    text.force_encoding('UTF-16LE')
  end
end

# TextEncoder#encode_with_ruby_encoding (lib/httparty/text_encoder.rb)

def encode_with_ruby_encoding
  encoding = Encoding.find(charset)
  # Encoding = 組み込みのEncodingクラス
  # => TextEncoder#charset
  text.force_encoding(encoding.to_s)
rescue ArgumentError
  text
end

# TextEncoder#charset (lib/httparty/text_encoder.rb)

def charset
  return nil if content_type.nil?

  if (matchdata = content_type.match(/;\s*charset\s*=\s*([^=,;"\s]+)/i))
    return matchdata.captures.first
  end

  if (matchdata = content_type.match(/;\s*charset\s*=\s*"((\\.|[^\\"])+)"/i))
    return matchdata.captures.first.gsub(/\\(.)/, '\1')
  end
end

# Request#parse_response (lib/httparty/request.rb)

def parse_response(body)
  parser.call(body, format) # options[:parser] => デフォルトではParser.call
end

# Parser.call (lib/httparty/parser.rb)

def self.call(body, format)
  new(body, format).parse
end

# Parser#initialize (lib/httparty/parser.rb)

def initialize(body, format)
  @body = body
  @format = format
end

# Parser#parse (lib/httparty/parser.rb)

def parse
  return nil if body.nil?
  return nil if body == 'null'
  return nil if body.valid_encoding? && body.strip.empty? # => String#valid_encoding?

  if body.valid_encoding? && body.encoding == Encoding::UTF_8
    @body = body.gsub(/\A#{UTF8_BOM}/, '') # UTF8_BOM = "\xEF\xBB\xBF"
  end

  if supports_format? # self.class.supports_format?(format) => Parser#supports_format / Parser.supports_format?
    parse_supported_format # => Parser#parse_supported_format
  else
    body
  end
end

# Parser.supports_format? (lib/httparty/parser.rb)

def self.supports_format?(format)
  supported_formats.include?(format)

  # => Parser.supported_format
  # => Parser.formats
  #
  # Parser.formats (lib/httparty/parser.rb)
  #
  #   def self.formats
  #     const_get(:SupportedFormats)
  #   end
  #
  #   SupportedFormats = {
  #     'text/xml'                    => :xml,   # MultiXml.parse(body)
  #     'application/xml'             => :xml,   # MultiXml.parse(body)
  #     'application/json'            => :json,  # JSON.parse(body, :quirks_mode => true, :allow_nan => true)
  #     'application/vnd.api+json'    => :json,  # JSON.parse(body, :quirks_mode => true, :allow_nan => true)
  #     'application/hal+json'        => :json,  # JSON.parse(body, :quirks_mode => true, :allow_nan => true)
  #     'text/json'                   => :json,  # JSON.parse(body, :quirks_mode => true, :allow_nan => true)
  #     'application/javascript'      => :plain, # body
  #     'text/javascript'             => :plain, # body
  #     'text/html'                   => :html,  # body
  #     'text/plain'                  => :plain, # body
  #     'text/csv'                    => :csv,   # CSV.parse(body)
  #     'application/csv'             => :csv,   # CSV.parse(body)
  #     'text/comma-separated-values' => :csv    # CSV.parse(body)
  #   }
end

# Parser#parse_supported_format (lib/httparty/parser.rb)

def parse_supported_format
  if respond_to?(format, true)
    send(format)
  else
    raise NotImplementedError,
          "#{self.class.name} has not implemented a parsing method for the #{format.inspect} format."
  end
end

# Response#initialize (lib/httparty/response.rb)

attr_reader :request, :response, :body, :headers

# request      = #<Request>
# response     = #<Net::HTTPOK>など。#<Net::HTTP>#request(@raw_request)の返り値 (last_response)
# parsed_block = lambda { parse_response(body) } Parser#parseを呼ぶ
# body         = responseに対して#bodyを呼んだ、もしくはそれにエンコーディングしたString
def initialize(request, response, parsed_block, options = {})
  @request      = request
  @response     = response
  @body         = options[:body] || response.body
  @parsed_block = parsed_block # レスポンスを整形して表示するときなどに使われているっぽい => Response#parsed_response
  @headers      = Headers.new(response.to_hash) # => Response::Headers#initialize

  if request.options[:logger]
    logger = ::HTTParty::Logger.build(
      request.options[:logger],
      request.options[:log_level],
      request.options[:log_format]
    )
    logger.format(request, self)
  end

  throw_exception
end

# Response::Headers#initialize (lib/httparty/response.rb)

include ::Net::HTTPHeader

def initialize(header_values = nil)
  @header = {}

  if header_values
    header_values.each_pair do |k,v|
      if v.is_a?(Array)
        v.each do |sub_v|
          add_field(k, sub_v) # => Net::HTTPHeader#add_field
        end
      else
        add_field(k, v) # => Net::HTTPHeader#add_field
      end
    end
  end

  # Net::HTTPHeader#add_field (net-http: lib/net/http/header.rb)
  #
  #   def add_field(key, val)
  #     stringified_downcased_key = key.downcase.to_s
  #
  #     if @header.key?(stringified_downcased_key)
  #       append_field_value(@header[stringified_downcased_key], val)
  #     else
  #       set_field(key, val)
  #     end
  #   end

  super(@header)
end
```
