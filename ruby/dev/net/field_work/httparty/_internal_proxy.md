# httparty 現地調査: プロキシ編 (202512時点)
- net-httpに受け渡しているだけではある

## `HTTParty.get`で指定

```ruby
HTTParty.get(
  "https://example.com",
  http_proxyaddr: "proxy.example.com",
  http_proxyport: 8080
)
```

```ruby
# HTTParty.get (lib/httparty.rb)

def get(path, options = {}, &block)
  # optionsにhttp_proxyaddr, http_proxyportなどが格納されている
  perform_request(Net::HTTP::Get, path, options, &block) # => HTTParty.perform_request
end

# HTTParty.perform_request (lib/httparty.rb)

def perform_request(http_method, path, options, &block) #:nodoc:
  # optionsにhttp_proxyaddr, http_proxyportなどが格納されている
  build_request(http_method, path, options).perform(&block)
  # => HTTParty.build_request
  # => Request#perform
end

# HTTParty.build_request  (lib/httparty.rb)

def build_request(http_method, path, options = {})
  # 引数optionsにhttp_proxyaddr, http_proxyportなどが格納されている
  options = ModuleInheritableAttributes.hash_deep_dup(default_options).merge(options)
  # => ModuleInheritableAttributes.hash_deep_dup
  # options = { http_proxyaddr:, http_proxyport:, ... }
  # default_optionsはHTTPartyクラスの属性。初期値として空ハッシュがセットされている
  #
  # HTTParty.included (lib/httparty.rb)
  #   def self.included(base)
  #     base.extend ClassMethods
  #     base.send :include, ModuleInheritableAttributes
  #     base.send(:mattr_inheritable, :default_options)
  #     base.send(:mattr_inheritable, :default_cookies)
  #     base.instance_variable_set(:@default_options, {})
  #     base.instance_variable_set(:@default_cookies, CookieHash.new)
  #   end

  HeadersProcessor.new(headers, options).call
  # => HeadersProcessor#initialize
  # => HeadersProcessor#call

  # HeadersProcessor#initialize (lib/httparty/headers_processor.rb)
  #
  #   def initialize(headers, options)
  #     @headers = headers
  #     @options = options # #<HeadersProcessor>のoptions属性にプロキシ情報がセットされる
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

  # optionsにhttp_proxyaddr, http_proxyportなどが格納されている
  Request.new(http_method, path, options) # => Request#initialize
end

# Request#initialize (lib/httparty/request.rb)

attr_accessor :http_method, :options, :last_response, :redirect, :last_uri

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
  }.merge(o) # Request#optionsにプロキシ情報がマージされる
  self.path = path

  set_basic_auth_from_uri # => Request#set_basic_auth_from_uri
end

# Request#perform (lib/httparty/request.rb)

def perform(&block)
  validate # => Request#validate
  setup_raw_request # => Request#setup_raw_request

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

# Request#setup_raw_request (lib/httparty/request.rb)

def setup_raw_request
  if options[:headers].respond_to?(:to_hash)
    headers_hash = options[:headers].to_hash
  else
    headers_hash = nil
  end

  # http_method = self.http_method (Net::HTTP::{リクエストを表すクラス})
  # uri         = #<URI::HTTPS> など => Request#uri
  # headers_hashとしてoptionsを渡しているが、この時点ではプロキシの情報は渡していない
  @raw_request = http_method.new(request_uri(uri), headers_hash) # => Request#request_uri

  # 以下はあまり関係ない
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

  if options[:basic_auth] && send_authorization_header? # => Request#send_authorization_header?
    @raw_request.basic_auth(username, password)
    @credentials_sent = true
  end

  if digest_auth? && response_unauthorized? && response_has_digest_auth_challenge?
    setup_digest_auth # => Request#setup_digest_auth
  end
end

# Request#http (lib/httparty/request/body.rb)

def http
  connection_adapter.call(uri, options)
  # => Request#uri
  # => Request#connection_adapter
  # => ConnectionAdapter.call
end

# Request#uri (lib/httparty/request.rb)

def uri
  if redirect && path.relative? && path.path[0] != '/'
    last_uri_host = @last_uri.path.gsub(/[^\/]+$/, '')

    path.path = "/#{path.path}" if last_uri_host[-1] != '/'
    path.path = "#{last_uri_host}#{path.path}"
  end

  if path.relative? && path.host
    new_uri = options[:uri_adapter].parse("#{@last_uri.scheme}:#{path}").normalize
  elsif path.relative?
    new_uri = options[:uri_adapter].parse("#{base_uri}#{path}").normalize
  else
    new_uri = path.clone
  end

  # avoid double query string on redirects [#12]
  unless redirect
    new_uri.query = query_string(new_uri)
  end

  unless SupportedURISchemes.include? new_uri.scheme
    raise UnsupportedURIScheme, "'#{new_uri}' Must be HTTP, HTTPS or Generic"
  end

  @last_uri = new_uri
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

  # optionsにプロキシ情報が格納されている
  @options = OPTION_DEFAULTS.merge(options)
end

# ConnectionAdapter#connection (lib/httparty/connection_adapter.rb)

def connection
  host = clean_host(uri.host) # StripIpv6BracketsRegex =~ host ? $1 : host => ConnectionAdapter#strip_ipv6_brackets
  port = uri.port || (uri.scheme == 'https' ? 443 : 80)

  # http_proxyaddrがセットされていないと無視される
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
    http = Net::HTTP.new(host, port) # この場合でも環境変数からプロキシを設定しているのでは?
  end

  # 以下はあまり関係ない

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
```

## クラスレベルで指定

```ruby
include HTTParty

base_uri "https://example.com"
http_proxy "proxy.example.com", 8080
```

```ruby
# HTTParty.http_proxy (lib/httparty.rb)

def http_proxy(addr = nil, port = nil, user = nil, pass = nil)
  default_options[:http_proxyaddr] = addr
  default_options[:http_proxyport] = port
  default_options[:http_proxyuser] = user
  default_options[:http_proxypass] = pass
  # 使われ方はHTTParty.getに指定した場合と同じ
end
```
