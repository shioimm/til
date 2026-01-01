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

# HTTParty.getに指定された設定はoptionsとして渡される
def get(path, options = {}, &block)
  perform_request(Net::HTTP::Get, path, options, &block)
  # => HTTParty.perform_request
end

# HTTParty.perform_request (lib/httparty.rb)

# HTTParty.getに指定された設定はoptionsとして渡される
def perform_request(http_method, path, options, &block) #:nodoc:
  build_request(http_method, path, options).perform(&block)
  # => HTTParty.build_request
  # => Request#perform
end

# HTTParty.build_request  (lib/httparty.rb)

# HTTParty.getに指定された設定はoptionsとして渡される
def build_request(http_method, path, options = {})
  options = ModuleInheritableAttributes.hash_deep_dup(default_options).merge(options)
  # => ModuleInheritableAttributes.hash_deep_dup
  # 自身の@default_optionsを複製してHTTParty.getに指定されたoptionsをmerge

  # HTTParty.getに指定された設定はHeadersProcessorの@options属性として保存される
  HeadersProcessor.new(headers, options).call
  # => HeadersProcessor#initialize
  # => HeadersProcessor#call

  # HeadersProcessor#initialize (lib/httparty/headers_processor.rb)
  #
  #   def initialize(headers, options)
  #     @headers = headers
  #     @options = options
  #   end

  process_cookies(options) # => HTTParty.process_cookies

  Request.new(http_method, path, options) # => Request#initialize
end
```
