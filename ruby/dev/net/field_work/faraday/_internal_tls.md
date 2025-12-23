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
connection = Faraday.new("https://example.com") { |conn|
  conn.ssl.verify = true # OpenSSL::SSL:VERIFY_PEER
  conn.ssl.ca_file = "/etc/ssl/certs/ca-certificates.crt"
  conn.ssl.ca_path = "/etc/ssl/certs"
  conn.ssl.client_cert = OpenSSL::X509::Certificate.new(File.read("client.crt"))
  conn.ssl.client_key  = OpenSSL::PKey::RSA.new(File.read("client.key"))
  conn.ssl.min_version = :TLS1_2
  conn.ssl.max_version = :TLS1_3
  conn.ssl.ciphers = "TLS_AES_128_GCM_SHA256"
}

res = connection.get("/")
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
    memoized(:ssl) { self.class.options_for(:ssl).new } # => SSLOptions
    memoized(:builder_class) { RackBuilder } # => RackBuilder

    def self.memoized(key, &block)
      unless block
        raise ArgumentError, '#memoized must be called with a block'
      end

      memoized_attributes[key.to_sym] = block

      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        remove_method(key) if method_defined?(key, false)
        def #{key}() self[:#{key}]; end
      RUBY
    end

    def self.memoized_attributes
      @memoized_attributes ||= {}
    end

    def self.options_for(key)
      attribute_options[key]
    end
  end

  # SSLOptions (lib/faraday/options/ssl_options.rb)

  # 外部から渡された設定を保存するためのOptions
  SSLOptions = Options.new(
    :verify, :verify_hostname,
    :ca_file, :ca_path, :verify_mode,
    :cert_store, :client_cert, :client_key,
    :certificate, :private_key, :verify_depth,
    :version, :min_version, :max_version, :ciphers
  ) do
    # @return [Boolean] true if should verify
    def verify?
      verify != false
    end

    # @return [Boolean] true if should not verify
    def disable?
      !verify?
    end

    # @return [Boolean] true if should verify_hostname
    def verify_hostname?
      verify_hostname != false
    end
  end
end

# Connection#initialize (lib/faraday/connection.rb)

attr_reader :ssl

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

  # @ssl = #<SSLOptions>
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

  # ブロックの中でアクセスしているsslは#<Connection>自身の@ssl (#<SSLOptions>)
  yield(self) if block_given?
  # #<Connection>のoptions経由で@ssl (#<SSLOptions>) に設定を保存できる

  @headers[:user_agent] ||= USER_AGENT
end
```
