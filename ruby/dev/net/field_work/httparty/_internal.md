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
    - `Request#perform` WIP ここから続き
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

## `HTTParty.get`

```ruby
# (lib/httparty.rb)

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
  # default_optionsはHTTPartyのattribute

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

  # HTTParty.process_cookies (lib/httparty.rb)
  #
  #   def process_cookies(options) #:nodoc:
  #     return unless options[:cookies] || default_cookies.any?
  #     options[:headers] ||= headers.dup
  #     options[:headers]['cookie'] = cookies.merge(options.delete(:cookies) || {}).to_cookie_string
  #   end

  Request.new(http_method, path, options) # => Request#initialize
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

  set_basic_auth_from_uri
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

  # WIP
  self.last_response = current_http.request(@raw_request) do |http_response|
    if block
      chunks = []

      http_response.read_body do |fragment|
        encoded_fragment = encode_text(fragment, http_response['content-type'])
        chunks << encoded_fragment if !options[:stream_body]
        block.call ResponseFragment.new(encoded_fragment, http_response, current_http)
      end

      chunked_body = chunks.join
    end
  end

  handle_host_redirection if response_redirects?
  result = handle_unauthorized
  result ||= handle_response(chunked_body, &block)
  result
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

  if options[:basic_auth] && send_authorization_header?
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
```
