# faraday 現地調査: TLS編 (202512時点)

## HTTPSを利用する
- httpsスキームを指定する

```ruby
conn = Faraday.new("https://example.com")
res  = conn.get("/")
puts res.body
```

- 明示的に設定を制御する

```ruby
conn = Faraday.new("https://example.com") { |f|
  f.ssl.verify = true # OpenSSL::SSL:VERIFY_PEER
  f.ssl.ca_file = "/etc/ssl/certs/ca-certificates.crt"
  f.ssl.ca_path = "/etc/ssl/certs"
  f.ssl.client_cert = OpenSSL::X509::Certificate.new(File.read("client.crt"))
  f.ssl.client_key  = OpenSSL::PKey::RSA.new(File.read("client.key"))
  f.ssl.min_version = :TLS1_2
  f.ssl.max_version = :TLS1_3
  f.ssl.ciphers = "TLS_AES_128_GCM_SHA256"
}

res  = conn.get("/")
puts res.body
```

## HTTPSを使うための設定を保存する

```ruby
# Faraday.new (lib/faraday.rb)
# e.g. Faraday.new("https://example.com")

def new(url = nil, options = {}, &block)
  options = Utils.deep_merge(default_connection_options, options)
  # => Faraday.default_connection_options
  # => Utils.deep_merge
  Faraday::Connection.new(url, options, &block) # => Connection#initialize
end

# Faraday.default_connection_options (lib/faraday.rb)

def default_connection_options
  @default_connection_options ||= ConnectionOptions.new # => ConnectionOptions
end

# ConnectionOptions (lib/faraday/options/connection_options.rb)

module Faraday
  ConnectionOptions = Options.new(
    :request, :proxy, :ssl, :builder, :url,
    :parallel_manager, :params, :headers,
    :builder_class
  ) do

    options request: RequestOptions, ssl: SSLOptions
    memoized(:request) { self.class.options_for(:request).new }
    # WIP
    memoized(:ssl) { self.class.options_for(:ssl).new }
    memoized(:builder_class) { RackBuilder } # => RackBuilder
  end
end

# Connection#initialize (lib/faraday/connection.rb)

# url     = String
# options = ConnectionOptions
def initialize(url = nil, options = nil)
  options = ConnectionOptions.from(options) # => Options.from

  if url.is_a?(Hash) || url.is_a?(ConnectionOptions)
    options = Utils.deep_merge(options, url) # => Utils.deep_merge
    url     = options.url
  end

  @parallel_manager = nil
  @headers = Utils::Headers.new
  @params  = Utils::ParamsHash.new
  @options = options.request
  @ssl = options.ssl
  @default_parallel_manager = options.parallel_manager
  @manual_proxy = nil

  @builder = options.builder || begin
    # pass an empty block to Builder so it doesn't assume default middleware
    options.new_builder(block_given? ? proc { |b| } : nil) # => ConnectionOptions#new_builder
  end

  # url_prefixに指定のURLを保存する
  self.url_prefix = url || 'http:/'

  @params.update(options.params)   if options.params
  @headers.update(options.headers) if options.headers

  initialize_proxy(url, options) # => Connection#initialize_proxy

  # WIP
  yield(self) if block_given?

  @headers[:user_agent] ||= USER_AGENT
end
```
