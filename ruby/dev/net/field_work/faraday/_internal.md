# faraday 現地調査 (202511時点)

## 全体の流れ
- `Faraday.new`
  - `Faraday.default_connection_options`
  - `Utils.deep_merge`
  - `Connection.initialize`
    - `RackBuilder#initialize`
      - `RackBuilder#build`
        - `RackBuilder#request` ハンドラの追加
          - `RackBuilder#use_symbol`
            - `RackBuilder#use`
              - `RackBuilder::Handler#initialize`
        - `RackBuilder#adapter` アダプタの追加
          - `RackBuilder::Handler#initialize`
- `Connection#get`
  - `Connection#run_request`
    - `Connection#build_request`
      - `Request.create`
    - `RackBuilder#build_response`
      - `RackBuilder#build_env`
        - `Env.new`
      - `RackBuilder#app`
        - `RackBuilder#to_app`
          - `RackBuilder::Handler#build` (`Faraday::Adapter::NetHttp`)
      - `{ハンドラ}#call` (`Request::UrlEncoded#call`)
        - `Request::UrlEncoded#match_content_type`
        - `{アダプタ}#call` (`Adapter::NetHttp#call`) WIP

## `Faraday.new`

```ruby
# (lib/faraday.rb)

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
```

### `Utils.deep_merge`

```ruby
# (lib/faraday/utils.rb)

def deep_merge!(target, hash)
  hash.each do |key, value|
    target[key] = if value.is_a?(Hash) && (target[key].is_a?(Hash) || target[key].is_a?(Options))
                    deep_merge(target[key], value)
                  else
                    value
                  end
  end
  target
end
```

## `Connection#initialize`

```ruby
# (lib/faraday/connection.rb)

def initialize(url = nil, options = nil)
  options = ConnectionOptions.from(options) # => ConnectionOptions

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

  self.url_prefix = url || 'http:/'

  @params.update(options.params)   if options.params
  @headers.update(options.headers) if options.headers

  initialize_proxy(url, options)

  yield(self) if block_given?

  @headers[:user_agent] ||= USER_AGENT
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
    memoized(:ssl) { self.class.options_for(:ssl).new }
    memoized(:builder_class) { RackBuilder } # => RackBuilder

    # ConnectionOptions#new_builder (lib/faraday/options/connection_options.rb)
    def new_builder(block)
      builder_class.new(&block) # => RackBuilder#initialize
    end
  end
end
```

## `RackBuilder#initialize`

```ruby
# (lib/faraday/rack_builder.rb)

def initialize(&block)
  @adapter = nil
  @handlers = []
  build(&block) # => RackBuilder#build
end

# RackBuilder#build (lib/faraday/rack_builder.rb)

def build
  raise_if_locked # raise StackLocked, LOCK_ERR if locked? => RackBuilder#raise_if_locked
  block_given? ? yield(self) : request(:url_encoded) # => RackBuilder#request
  adapter(Faraday.default_adapter, **Faraday.default_adapter_options) unless @adapter # => RackBuilder#adapter
end

# RackBuilder#request (lib/faraday/rack_builder.rb)

def request(key, ...)
  use_symbol(Faraday::Request, key, ...)
  # => Faraday::Request
  # => RackBuilder#use_symbol
end

# RackBuilder#use_symbol (lib/faraday/rack_builder.rb)

def use_symbol(mod, key, ...)
  # mod = Faraday::Request
  # key = :url_encoded
  use(mod.lookup_middleware(key), ...)
  # => MiddlewareRegistry#lookup_middleware (Faraday::Request::UrlEncoded)
  # => RackBuilder#use
end

# MiddlewareRegistry#lookup_middleware (lib/faraday/middleware_registry.rb)

# key = :url_encoded
def lookup_middleware(key)
  load_middleware(key) || # => MiddlewareRegistry#load_middleware ここではFaraday::Request::UrlEncodedを返す
    raise(Faraday::Error, "#{key.inspect} is not registered on #{self}")

  # MiddlewareRegistry#load_middleware (lib/faraday/middleware_registry.rb)
  #
  #   def load_middleware(key)
  #     value = registered_middleware[key] # => MiddlewareRegistry#registered_middleware
  #
  #     # MiddlewareRegistry#registered_middleware (lib/faraday/middleware_registry.rb)
  #     #   def registered_middleware = @registered_middleware ||= {}
  #
  #     case value
  #     when Module
  #       value
  #     when Symbol, String
  #       middleware_mutex do
  #         @registered_middleware[key] = const_get(value)
  #       end
  #     when Proc
  #       middleware_mutex do
  #         @registered_middleware[key] = value.call
  #       end
  #     end
  #   end
end

# RackBuilder#use (lib/faraday/rack_builder.rb))

# klass = Faraday::Request::UrlEncoded
def use(klass, ...)
  if klass.is_a? Symbol
    use_symbol(Faraday::Middleware, klass, ...) # => RackBuilder#use_symbol
  else
    raise_if_locked # raise StackLocked, LOCK_ERR if locked? => RackBuilder#raise_if_locked
    raise_if_adapter(klass) # => RackBuilder#raise_if_adapter

    @handlers << self.class::Handler.new(klass, ...) # => RackBuilder::Handler#initialize
    # RackBuilder::Handler.new(Faraday::Request::UrlEncoded)
  end
end

# RackBuilder#adapter (lib/faraday/rack_builder.rb)

# klass = Faraday.default_adapter
# args = Faraday.default_adapter_options

# (lib/faraday.rb)
# module Faraday
#   self.default_adapter = :net_http
#   self.default_adapter_options = {}
# end

def adapter(klass = NO_ARGUMENT, *args, &block)
  return @adapter if klass == NO_ARGUMENT || klass.nil?

  klass = Faraday::Adapter.lookup_middleware(klass) if klass.is_a?(Symbol)
  # Faraday.default_adapterが:net_httpの場合、klass = Faraday::Adapter::NetHttp

  @adapter = self.class::Handler.new(klass, *args, &block) # => RackBuilder::Handler#initialize
  # RackBuilder::Handler.new(Faraday::Adapter::NetHttp)
end

# RackBuilder::Handler#initialize (lib/faraday/rack_builder.rb)

REGISTRY = Faraday::AdapterRegistry.new
# AdapterRegistryは内部に@lock = Monitorと@constants = {}を持つ。
# AdapterRegistry#setで指定のキーに任意の値を保存し、AdapterRegistry#getで取り出す

def initialize(klass, *args, &block)
  @name = klass.to_s # REGISTRY.get(@name) => RackBuilder::Handler#klass
  REGISTRY.set(klass) if klass.respond_to?(:name)
  @args = args
  @block = block
end
```

## `Connection#get`

```ruby
# (lib/faraday/connection.rb)

class Connection
  # ...
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

def run_request(method, url, body, headers)
  # METHODS = Set.new %i[get post put delete head patch options trace]
  unless METHODS.include?(method)
    raise ArgumentError, "unknown http method: #{method}"
  end

  # 呼び出し側 (Connection)
  #   run_request(:#{method}, url, nil, headers) do |request|
  #     request.params.update(params) if params
  #     yield request if block_given?
  #   end

  request = build_request(method) do |req| # => Connection#build_request
    req.options.proxy = proxy_for_request(url) # => Connection#proxy_for_request
    req.url(url)                if url     # => Request#url
    req.headers.update(headers) if headers # => Utils::Headers#update
    req.body = body             if body    # => Request#body=

    yield(req) if block_given?
  end

  builder.build_response(self, request) # self = #<Connection>
  # attr_reader :builder (Faraday::RackBuilder)
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

# Request (lib/faraday/request.rb)

module Faraday
  Request = Struct.new(:http_method, :path, :params, :headers, :body, :options) do
    extend MiddlewareRegistry

    alias_method :member_get, :[]
    private :member_get
    alias_method :member_set, :[]=
    private :member_set

    def self.create(request_method)
      new(request_method).tap do |request|
        yield(request) if block_given?
      end
    end

    # ...
  end
end

# RackBuilder#build_response (lib/faraday/rack_builder.rb)

def build_response(connection, request)
  env = build_env(connection, request)
  # => Request::UrlEncoded#call

  app.call(env)
  # => RackBuilder#build_env
  # => RackBuilder#app
end

# RackBuilder#build_env (lib/faraday/rack_builder.rb)

def build_env(connection, request)
  exclusive_url = connection.build_exclusive_url(
    request.path,
    request.params,
    request.options.params_encoder
  )

  Env.new( # => Faraday::Env (lib/faraday/options/env.rb)
    request.http_method,
    request.body, exclusive_url,
    request.options,
    request.headers,
    connection.ssl,
    connection.parallel_manager
  )
end

# RackBuilder#app (lib/faraday/rack_builder.rb)

def app
  @app ||= begin
    lock! # @handlers.freeze => RackBuilder#lock!
    ensure_adapter! # raise MISSING_ADAPTER_ERROR unless @adapter => RackBuilder#ensure_adapter!

    to_app # => RackBuilder#to_app
  end

  # #<Faraday::Request::UrlEncoded:0x000000011c438128
  #   @app=#<Faraday::Adapter::NetHttp:0x0000000101423f40
  #          @ssl_cert_store=nil,
  #          @app=#<Proc:0x000000011c438240(&:response) (lambda)>,
  #   @connection_options={},
  #   @config_block=nil>,
  #   @options={}>
end

# RackBuilder#to_app (lib/faraday/rack_builder.rb)

def to_app
  # @handlers = [Faraday::Request::UrlEncoded (Faraday::RackBuilder::Handle) ]
  #   - RackBuilder#initialize時に空配列で初期化される
  #   - RackBuilder::Handler#insert, RackBuilder::Handler#delete, ...などで操作される
  #   - @handlersに値を追加するのはRackBuilder#use, RackBuilder#insert
  # @adapter = Faraday::Adapter::NetHttp (Faraday::RackBuilder::Handler)
  #   - RackBuilder#initialize時にnilで初期化される
  #   - RackBuilder#adapterで値が追加される
  # Rackっぽいアーキテクチャになっている
  @handlers.reverse.inject(@adapter.build) do |app, handler| # => RackBuilder::Handler#build
    handler.build(app) # => RackBuilder::Handler#build↲
  end
end

# RackBuilder::Handler#build (lib/faraday/rack_builder.rb)

def build(app = nil)
  klass.new(app, *@args, &@block)
  # Faraday::Request::UrlEncoded.new
  # Faraday::Adapter::NetHttp.new
end

# Request::UrlEncoded#call (lib/faraday/request/url_encoded.rb)

def call(env)
  match_content_type(env) do |data| # => Request::UrlEncoded#match_content_type
    # data = env.body
    params = Faraday::Utils::ParamsHash[data]
    env.body = params.to_query(env.params_encoder)
  end

  @app.call env # => Adapter::NetHttp#call
end

# Request::UrlEncoded#match_content_type (lib/faraday/request/url_encoded.rb)

def match_content_type(env)
  return unless process_request?(env) # => Request::UrlEncoded#process_request?

  # Request::UrlEncoded#process_request? (lib/faraday/request/url_encoded.rb)
  #
  #   def process_request?(env)
  #     type = request_type(env) # => Request::UrlEncoded#request_type
  #     env.body && (type.empty? || (type == self.class.mime_type))
  #   end
  #
  # Request::UrlEncoded#request_type (lib/faraday/request/url_encoded.rb)
  #
  #   def request_type(env)
  #     type = env.request_headers[CONTENT_TYPE].to_s
  #
  #     type = type.split(';', 2).first if type.index(';')
  #     type
  #   end

  # env.request_headers = {"User-Agent" => "Faraday v2.12.2"}
  # CONTENT_TYPE = "Content-Type"
  env.request_headers[CONTENT_TYPE] ||= self.class.mime_type
  return if env.body.respond_to?(:to_str) || env.body.respond_to?(:read)

  yield(env.body)
end
```

## `Adapter::NetHttp` (faraday-net_http: lib/faraday/adapter/net_http.rb)

```ruby
module Faraday
  module NetHttp
    Faraday::Adapter.register_middleware(net_http: Faraday::Adapter::NetHttp)
  end

  class Adapter
    class NetHttp < Faraday::Adapter

    # Adapter::NetHttp#call

    def call
      # WIP 先にinitializeが呼ばれている箇所を特定したい
    end
  end
end
```
