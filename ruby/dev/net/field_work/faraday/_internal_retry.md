# faraday 現地調査 (faraday-retry-2.4.0時点)
## 気づいたこと
- ミドルウェアを利用する必要あり

## リトライの設定

```ruby
require "faraday"
require "faraday/retry"

conn = Faraday.new("https://example.com") { |rack|
  rack.request :retry, # => RackBuilder#request
               max: 3,                   # 最大リトライ回数
               interval: 0.5,            # 初期待機時間(s)
               interval_randomness: 0.5, # ジッタ
               backoff_factor: 2,        # 指数バックオフ
               exceptions: [             # 対象エラー
                 Faraday::ConnectionFailed
               ]

  rack.adapter Faraday.default_adapter
}

conn.get
```

## リトライの実行
### ミドルウェアの登録

```ruby
# Faraday::Retry (faraday-retry: lib/faraday/retry.rb)

module Faraday
  # Middleware main module.
  module Retry
    Faraday::Request.register_middleware(retry: Faraday::Retry::Middleware)
  end
end

# MiddlewareRegistry#register_middleware (lib/faraday/middleware_registry.rb)

def register_middleware(**mappings)
  middleware_mutex do
    # @registered_middlewareに{ retry: Faraday::Retry::Middleware }をセット
    registered_middleware.update(mappings)
  end
end

# MiddlewareRegistry#middleware_mutex (lib/faraday/middleware_registry.rb)

def middleware_mutex(&block)
  @middleware_mutex ||= Monitor.new
  @middleware_mutex.synchronize(&block)
end
```

### Connectionオブジェクトの作成

```ruby
# Faraday.new (lib/faraday.rb)

def new(url = nil, options = {}, &block)
  options = Utils.deep_merge(default_connection_options, options)
  # => Faraday.default_connection_options
  # => Utils.deep_merge
  Faraday::Connection.new(url, options, &block) # => Connection#initialize
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

  self.url_prefix = url || 'http:/'

  @params.update(options.params)   if options.params
  @headers.update(options.headers) if options.headers

  initialize_proxy(url, options) # => Connection#initialize_proxy

  yield(self) if block_given?

  @headers[:user_agent] ||= USER_AGENT
end

# ConnectionOptions#new_builder (lib/faraday/options/connection_options.rb)

def new_builder(block)
  builder_class.new(&block) # => RackBuilder#initialize
end

# RackBuilder#initialize (lib/faraday/rack_builder.rb)

def initialize(&block)
  @adapter = nil
  @handlers = []
  build(&block) # => RackBuilder#build
end

# RackBuilder#build (lib/faraday/rack_builder.rb)

def build
  raise_if_locked # raise StackLocked, LOCK_ERR if locked? => RackBuilder#raise_if_locked
  block_given? ? yield(self) : request(:url_encoded) # => RackBuilder#request

  # 呼び出し側
  #
  #   Faraday.new("https://example.com") do |rack|
  #     rack.request :retry, # => RackBuilder#request
  #                  max: 3,                   # 最大リトライ回数
  #                  interval: 0.5,            # 初期待機時間(s)
  #                  interval_randomness: 0.5, # ジッタ
  #                  backoff_factor: 2,        # 指数バックオフ
  #                  exceptions: [             # 対象エラー
  #                    Faraday::ConnectionFailed
  #                  ]
  #
  #     rack.adapter Faraday.default_adapter
  #   end

  # (lib/faraday.rb)
  # module Faraday
  #   self.default_adapter = :net_http
  #   self.default_adapter_options = {}
  # end
  adapter(Faraday.default_adapter, **Faraday.default_adapter_options) unless @adapter

  # => RackBuilder#adapter
end

# RackBuilder#request (lib/faraday/rack_builder.rb)

# key = :retry
def request(key, ...)
  use_symbol(Faraday::Request, key, ...)
  # => Faraday::Request
  # => RackBuilder#use_symbol
end

# RackBuilder#use_symbol (lib/faraday/rack_builder.rb)

# mod = Faraday::Request
# key = :retry
def use_symbol(mod, key, ...)
  handler = mod.lookup_middleware(key)
  # => MiddlewareRegistry#lookup_middleware
  use(handler, ...)
  # => RackBuilder#use
end

# MiddlewareRegistry#lookup_middleware (lib/faraday/middleware_registry.rb)

# key = :retryなどのハンドラ、もしくは:net_httpなどのアダプタ
def lookup_middleware(key)
  load_middleware(key) || # => MiddlewareRegistry#load_middleware
    raise(Faraday::Error, "#{key.inspect} is not registered on #{self}")
end

# MiddlewareRegistry#load_middleware (lib/faraday/middleware_registry.rb)

def load_middleware(key)
  value = registered_middleware[key] # => MiddlewareRegistry#registered_middleware

  # MiddlewareRegistry#registered_middleware (lib/faraday/middleware_registry.rb)
  #   def registered_middleware = @registered_middleware ||= {}

  case value
  when Module         then value
  when Symbol, String then middleware_mutex { @registered_middleware[key] = const_get(value) }
  when Proc           then middleware_mutex { @registered_middleware[key] = value.call }
  end
end

# RackBuilder#use (lib/faraday/rack_builder.rb)

# klass = Faraday::Retry::Middleware
def use(klass, ...)
  if klass.is_a? Symbol
    use_symbol(Faraday::Middleware, klass, ...) # => RackBuilder#use_symbol
  else
    raise_if_locked # raise StackLocked, LOCK_ERR if locked? => RackBuilder#raise_if_locked
    raise_if_adapter(klass) # => RackBuilder#raise_if_adapter

    @handlers << self.class::Handler.new(klass, ...) # => RackBuilder::Handler#initialize
  end
end

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

### Connectionオブジェクトを使ったリクエスト


```ruby
# Connection#get (lib/faraday/connection.rb)
# e.g. Faraday.new(url: "http://example.com").get("/index.html")

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

  request = build_request(method) do |req| # => Connection#build_request #<Request>を返す
    req.options.proxy = proxy_for_request(url) # => Connection#proxy_for_request
    req.url(url)                if url         # => Request#url
    req.headers.update(headers) if headers     # => Utils::Headers#update
    req.body = body             if body        # => Request#body=

    yield(req) if block_given?
  end

  # attr_reader :builder (#<Faraday::RackBuilder>)
  # self    = #<Connection>
  # request = #<Request>
  builder.build_response(self, request)
  # => RackBuilder#build_response
end

# RackBuilder#build_response (lib/faraday/rack_builder.rb)

def build_response(connection, request)
  env = build_env(connection, request)
  # => RackBuilder#build_env

  app.call(env)
  # => RackBuilder#app
  # => Retry::Middleware#call
end

def app
  @app ||= begin
    lock! # @handlers.freeze => RackBuilder#lock!
    ensure_adapter! # raise MISSING_ADAPTER_ERROR unless @adapter => RackBuilder#ensure_adapter!
    to_app # => RackBuilder#to_app
  end

  # @app = ハンドラがアダプタをラップする構造
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
  # @adapter  = Faraday::Adapter::NetHttp
  builded_adapter = @adapter.build # => Adapter::NetHttp::Handler#build (RackBuilder::Handler#build)

  # @handlers = [Faraday::Retry::Middleware]
  @handlers.reverse.inject(builded_adapter) do |app, handler|
    handler.build(app) # => Retry::Middlewar#build (RackBuilder::Handler#build)
  end
end

# RackBuilder::Handler#build (lib/faraday/rack_builder.rb)

def build(app = nil)
  # ハンドラでラップしたクラスのオブジェクトを生成する
  klass.new(app, *@args, &@block)
  # => ({アダプタ}.buildの場合) Adapter::NetHttp#initialize (appはnil)
  # => ({ハンドラ}.buildの場合) Retry::Middleware#initialize (appは#<Adapter::NetHttp>)
end

# Retry::Middleware#initialize (faraday-retry: lib/faraday/retry/middleware.rb)

def initialize(app, options = nil)
  super(app)
  @options = Options.from(options) # Options#from
  @errmatch = build_exception_matcher(@options.exceptions)
  # => Options#exceptions
  # => Retry::Middleware#build_exception_matcher

  # Options#exceptions (faraday-retry: lib/faraday/retry/middleware.rb)
  #
  #   def exceptions
  #     Array(self[:exceptions] ||= DEFAULT_EXCEPTIONS)
  #   end
  #
  #   DEFAULT_EXCEPTIONS = [
  #     Errno::ETIMEDOUT, 'Timeout::Error',
  #     Faraday::TimeoutError, Faraday::RetriableResponse
  #   ].freeze
end

RetryOprions = Faraday::Options.new(
  :max,
  :interval,
  :max_interval,
  :interval_randomness,
  :backoff_factor,
  :exceptions,
  :methods,
  :retry_if,
  :retry_block,
  :retry_statuses,
  :rate_limit_retry_header,
  :rate_limit_reset_header,
  :header_parser_block,
  :exhausted_retries_block
)

class Options < RetryOprions

  # Options#from (faraday-retry: lib/faraday/retry/middleware.rb)

  def self.from(value)
    if value.is_a?(Integer)
      new(value)
    else
      super(value)
    end
  end
end

# Retry::Middleware#build_exception_matcher (faraday-retry: lib/faraday/retry/middleware.rb)

def build_exception_matcher(exceptions)
  matcher = Module.new(
    class << matcher
      self
    end
  ).class_eval do
    define_method(:===) do |error| # === 引数の例外がリトライ対象かどうかを確認するメソッド
      exceptions.any? do |ex|
        if ex.is_a? Module
          error.is_a? ex
        else
          Object.const_defined?(ex.to_s) && error.is_a?(Object.const_get(ex.to_s))
        end
      end
    end
  end

  matcher
end

# Retry::Middleware#call (faraday-retry: lib/faraday/retry/middleware.rb)

def call(env)
  retries = @options.max # 最大試行回数 => Options#max

  # Options#max (faraday-retry: lib/faraday/retry/middleware.rb)
  #
  #   def max
  #     (self[:max] ||= 2).to_i # デフォルトでは2回
  #   end

  request_body = env[:body]

  with_retries(env: env, options: @options, retries: retries, body: request_body, errmatch: @errmatch) do
    # => Retryable#with_retries

    # after failure env[:body] is set to the response body
    env[:body] = request_body

    @app.call(env).tap do |resp| # {内側のアダプタ}#call
      raise Faraday::RetriableResponse.new(nil, resp) if @options.retry_statuses.include?(resp.status)
      # => Retry::Middleware::Options#retry_statuses

      # Retry::Middleware::Options#retry_statuses (faraday-retry: lib/faraday/retry/middleware.rb))
      #
      #   def retry_statuses
      #     Array(self[:retry_statuses] ||= [])
      #   end
    end
  end
end

# Retryable#with_retries (faraday-retry: lib/faraday/retry/retryable.rb)

# 呼び出し側
#   with_retries(env: env, options: @options, retries: retries, body: request_body, errmatch: @errmatch) do
#     env[:body] = request_body
#     @app.call(env).tap do |resp|
#       raise Faraday::RetriableResponse.new(nil, resp) if @options.retry_statuses.include?(resp.status)
#     end
#   end
def with_retries(env:, options:, retries:, body:, errmatch:)
  yield
rescue errmatch => e # 指定の例外をrescue
  # (これ以上) リトライできないとき、外部から明示されたコールバックを呼ぶことができる
  exhausted_retries(options, env, e) if retries_zero?(retries, env, e)

  # WIP
  if retries.positive? && retry_request?(env, e)
    retries -= 1
    rewind_files(body)
    if (sleep_amount = calculate_sleep_amount(retries + 1, env))
      options.retry_block.call(
        env: env,
        options: options,
        retry_count: options.max - (retries + 1),
        exception: e,
        will_retry_in: sleep_amount
      )
      sleep sleep_amount
      retry
    end
  end

  raise unless e.is_a?(Faraday::RetriableResponse)

  e.response
end

# Retryable#retries_zero? (faraday-retry: lib/faraday/retry/retryable.rb)

def retries_zero?(retries, env, exception)
  retries.zero? && retry_request?(env, exception) # => Retry::Middleware#retry_request?
end

# Retry::Middleware#retry_request? (faraday-retry: lib/faraday/retry/middleware.rb)

def retry_request?(env, exception)
  @options.methods.include?(env[:method]) || # => Retry::Middleware::Options#methods
    @options.retry_if.call(env, exception) # => Retry::Middleware::Options#retry_if
end

# Retry::Middleware::Options#methods (faraday-retry: lib/faraday/retry/middleware.rb)

def methods
  Array(self[:methods] ||= IDEMPOTENT_METHODS)
  # IDEMPOTENT_METHODS = %i[delete get head options put].freeze
end

# Retry::Middleware::Options#retry_if (faraday-retry: lib/faraday/retry/middleware.rb)

def retry_if
  self[:retry_if] ||= DEFAULT_CHECK
  # DEFAULT_CHECK = ->(_env, _exception) { false }
end

# Retryable#exhausted_retries (faraday-retry: lib/faraday/retry/retryable.rb)

def exhausted_retries(options, env, exception)
  options.exhausted_retries_block.call(
    env: env,
    exception: exception,
    options: options
  )
end

# Retry::Middleware::Options#exhausted_retries_block ((faraday-retry: lib/faraday/retry/middleware.rb))

def exhausted_retries_block
  self[:exhausted_retries_block] ||= proc {}
end
```
