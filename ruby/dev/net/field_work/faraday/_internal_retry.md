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

WIP
