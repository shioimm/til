# httparty 現地調査: プロキシ編 (202512時点)

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
  options = ModuleInheritableAttributes.hash_deep_dup(default_options).merge(options)
  # => ModuleInheritableAttributes.hash_deep_dup
  # default_options (Hash) を複製 (値も)
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
  #     @options = options # 指定の値が#<HeadersProcessor>のoptions属性にセットされる
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

# Request#perform (lib/httparty/request.rb)

def perform(&block)
  validate # => Request#validate
  # WIP
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
```

## クラスレベルで指定

```ruby
include HTTParty

base_uri "https://example.com"
http_proxy "proxy.example.com", 8080
```
