# faraday 現地調査: TLS編 (202512時点)

## HTTPSを利用する
- httpsスキームを指定する

```ruby
conn = Faraday.new("https://example.com")
res  = conn.get("/")
puts res.body

conn = Faraday.new
res  = conn.get("https://example.com/")
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

## HTTPSで接続する

```ruby
# Connection#get (lib/faraday/connection.rb)

class Connection
  # ...
  METHODS_WITH_QUERY = %w[get head delete trace].freeze
  # Connection#get など (lib/faraday/connection.rb)
  METHODS_WITH_QUERY.each do |method| # => Connection#run_request
    class_eval <<-RUBY, __FILE__, __LINE__ + 1
      def #{method}(url = nil, params = nil, headers = nil)
        run_request(:#{method}, url, nil, headers) do |request|
          request.params.update(params) if params
          yield request if block_given?
        end
      end
    RUBY
  end

  # ...
end

# Connection#run_request (lib/faraday/connection.rb)

METHODS = Set.new %i[get post put delete head patch options trace]

def run_request(method, url, body, headers)
  unless METHODS.include?(method)
    raise ArgumentError, "unknown http method: #{method}"
  end

  # 呼び出し側 (Connection)
  #   run_request(:#{method}, url, nil, headers) do |request|
  #     request.params.update(params) if params
  #     yield request if block_given?
  #   end

  request = build_request(method) do |req| # => Connection#build_request #<Request>を返す
    req.options.proxy = proxy_for_request(url) # => Connection#proxy_for_request

    # urlとしてURLもしくはパスが渡される
    req.url(url) if url # => Request#url

    req.headers.update(headers) if headers # => Utils::Headers#update
    req.body = body if body # => Request#body=

    yield(req) if block_given?
  end

  # attr_reader :builder (#<Faraday::RackBuilder>)
  # self    = #<Connection>
  # request = #<Request>
  builder.build_response(self, request)
  # => RackBuilder#build_response
end


# Connection#build_request (lib/faraday/connection.rb)

def build_request(method)
  Request.create(method) do |req| # => Request.create
    req.params  = params.dup  # => Request#params=
    req.headers = headers.dup # => Request#headers=
    req.options = options.dup # => Request#options=

    yield(req) if block_given?
  end
end

# RackBuilder#build_response (lib/faraday/rack_builder.rb)

# WIP
def build_response(connection, request)
  env = build_env(connection, request)
  # => RackBuilder#build_env

  app.call(env)
  # => RackBuilder#app
  # => {一番外側のハンドラ}#call (Request::UrlEncoded#call)
end
```
