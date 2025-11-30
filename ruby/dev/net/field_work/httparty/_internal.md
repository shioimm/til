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
```
