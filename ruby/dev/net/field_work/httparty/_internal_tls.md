# httparty 現地調査: TLS編 (202512時点)
## HTTPSを利用する
- httpsスキームを指定する

```ruby
res = HTTParty.get("https://example.com/")
p res.body
```

- 明示的に設定を制御する

```ruby
store = OpenSSL::X509::Store.new
store.set_default_paths

HTTParty.get(
  "https://example.com",
  ssl_ca_file: "/etc/ssl/certs/ca-certificates.crt",
  ssl_ca_path: "/etc/ssl/certs",
  pem:         File.read("client.pem"),
  pkcs12:      File.read("client.p12"),
  ssl_version: :TLSv1_2,
  ciphers:     "TLS_AES_128_GCM_SHA256",
)

p res.body
```

- 初期設定を保存する

```ruby
class MyClient
  include HTTParty

  base_uri "https://example.com" # => HTTParty::ClassMethods#base_uri

  ssl_ca_file "/etc/ssl/certs/ca-certificates.crt" # => HTTParty::ClassMethods#ssl_ca_file
  ssl_ca_path "/etc/ssl/certs"                     # => HTTParty::ClassMethods#ssl_ca_path
  pem         File.read("client.pem"), "password"  # => HTTParty::ClassMethods#pem
  pkcs12      File.read("client.p12"), "password"  # => HTTParty::ClassMethods#pkcs12
  ssl_version :TLSv1_2                             # => HTTParty::ClassMethods#ssl_version
  ciphers     "TLS_AES_128_GCM_SHA256"             # => HTTParty::ClassMethods#ssl_ciphers
end

MyClient.get("/")
```

## HTTPSを使うための設定を保存する

```ruby
module HTTParty
  def self.included(base)
    base.extend ClassMethods
    base.send :include, ModuleInheritableAttributes
    base.send(:mattr_inheritable, :default_options)
    base.send(:mattr_inheritable, :default_cookies)
    base.instance_variable_set(:@default_options, {})
    base.instance_variable_set(:@default_cookies, CookieHash.new)
  end

  # 初期設定値は自身の@default_optionsに保存される
  module ClassMethods
    # ...
    def base_uri(uri = nil)
      return default_options[:base_uri] unless uri
      default_options[:base_uri] = HTTParty.normalize_base_uri(uri)
    end

    def ssl_ca_file(path)
      default_options[:ssl_ca_file] = path
    end

    def ssl_ca_path(path)
      default_options[:ssl_ca_path] = path
    end

    def pem(pem_contents, password = nil)
      default_options[:pem] = pem_contents
      default_options[:pem_password] = password
    end

    def pkcs12(p12_contents, password)
      default_options[:p12] = p12_contents
      default_options[:p12_password] = password
    end

    def ssl_version(version)
      default_options[:ssl_version] = version
    end

    def ciphers(cipher_names)
      default_options[:ciphers] = cipher_names
    end
    # ...

    attr_reader :default_options
  end
end
```

```ruby
# HTTParty.get (lib/httparty.rb)

# HTTParty.getに指定された宛先はpath、設定はoptionsとして渡される
def get(path, options = {}, &block)
  perform_request(Net::HTTP::Get, path, options, &block)
  # => HTTParty.perform_request
end

# HTTParty.perform_request (lib/httparty.rb)

# HTTParty.getに指定された宛先はpath、設定はoptionsとして渡される
def perform_request(http_method, path, options, &block) #:nodoc:
  build_request(http_method, path, options).perform(&block)
  # => HTTParty.build_request
  # => Request#perform
end

# HTTParty.build_request  (lib/httparty.rb)

# HTTParty.getに指定された宛先はpath、設定はoptionsとして渡される
def build_request(http_method, path, options = {})
  options = ModuleInheritableAttributes.hash_deep_dup(default_options).merge(options)
  # => ModuleInheritableAttributes.hash_deep_dup
  # 自身の@default_optionsを複製してHTTParty.getに指定されたoptionsをmerge

  # デフォルト + HTTParty.getに指定された設定はHeadersProcessorの@options属性として保存される
  # @optionsのうち、@options[:headers]がHeadersProcessorの@headers属性にmergeされる
  HeadersProcessor.new(headers, options).call
  # => HeadersProcessor#initialize
  # => HeadersProcessor#call

  # HeadersProcessor#initialize (lib/httparty/headers_processor.rb)
  #
  #   attr_reader :headers, :options
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
  #
  #     options[:headers] = headers.merge(options[:headers]) if headers.any?
  #     options[:headers] = Utils.stringify_keys(process_dynamic_headers)
  #   end

  process_cookies(options) # => HTTParty.process_cookies

  # HTTParty.getに指定された宛先はURIに変換されたうえでRequestの@path属性として保存される
  # デフォルト + HTTParty.getに指定された設定はRequestの@options属性として保存される
  Request.new(http_method, path, options) # => Request#initialize
end

# Request#initialize (lib/httparty/request.rb)

attr_accessor :http_method, :options, :last_response, :redirect, :last_uri
attr_reader :path

def initialize(http_method, path, o = {})
  @changed_hosts = false
  @credentials_sent = false

  self.http_method = http_method

  # デフォルト + HTTParty.getに指定された設定はRequestの@options属性として保存される
  self.options = {
    limit: o.delete(:no_follow) ? 1 : 5,
    assume_utf16_is_big_endian: true,
    default_params: {},
    follow_redirects: true,
    parser: Parser, # HTTParty::Parser
    uri_adapter: URI,
    connection_adapter: ConnectionAdapter # HTTParty::ConnectionAdapter
  }.merge(o)

  # HTTParty.getに指定された宛先はURIに変換されたうえでRequestの@path属性として保存される
  self.path = path # => Request#path=

  set_basic_auth_from_uri # => Request#set_basic_auth_from_uri
end

# Request#path= (lib/httparty/request.rb)

def path=(uri)
  uri_adapter = options[:uri_adapter] # デフォルトではURI

  @path = if uri.is_a?(uri_adapter)
    uri
  elsif String.try_convert(uri)
    uri_adapter.parse(uri).normalize
  else
    raise ArgumentError,
      "bad argument (expected #{uri_adapter} object or URI string)"
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

# Request#setup_raw_request (lib/httparty/request.rb)

def setup_raw_request
  if options[:headers].respond_to?(:to_hash)
    headers_hash = options[:headers].to_hash
  else
    headers_hash = nil
  end

  # http_method = self.http_method (Net::HTTP::{リクエストを表すクラス})
  # uri         = #<URI::HTTPS> など => Request#uri ノーマライズしたURIを@last_uriに保存
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

  if options[:basic_auth] && send_authorization_header? # => Request#send_authorization_header?
    @raw_request.basic_auth(username, password)
    @credentials_sent = true
  end

  if digest_auth? && response_unauthorized? && response_has_digest_auth_challenge?
    setup_digest_auth # => Request#setup_digest_auth
  end
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

# Request#http (lib/httparty/request/body.rb)

def http
  connection_adapter.call(uri, options)
  # => Request#connection_adapter デフォルトではConnectionAdapter
  # => ConnectionAdapter.call
end

# ConnectionAdapter.call (lib/httparty/connection_adapter.rb)

def self.call(uri, options)
  new(uri, options).connection
  # => ConnectionAdapter#initialize
  # => ConnectionAdapter#connection WIP
end

# ConnectionAdapter#initialize (lib/httparty/connection_adapter.rb)

def initialize(uri, options = {})
  uri_adapter = options[:uri_adapter] || URI
  raise ArgumentError, "uri must be a #{uri_adapter}, not a #{uri.class}" unless uri.is_a? uri_adapter

  @uri = uri
  @options = OPTION_DEFAULTS.merge(options)
end
```
