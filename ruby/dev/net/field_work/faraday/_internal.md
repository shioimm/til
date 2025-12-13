# faraday 現地調査 (202511時点)

## 全体の流れ
- `Faraday.default_adapter`のセット
- `Faraday.default_adapter_options`のセット
- `Faraday.new`
  - `Faraday.default_connection_options`
    - `ConnectionOptions.new`
  - `Utils.deep_merge`
  - `Connection#initialize`
    - `ConnectionOptions#new_builder`
      - `RackBuilder#initialize`
        - `RackBuilder#build`
          - `RackBuilder#request`
            - `RackBuilder#use_symbol`
              - `RackBuilder#use` ハンドラの追加
                - `Middleware.lookup_middleware` ハンドラの特定
                - `RackBuilder::Handler#initialize` ハンドラクラスオブジェクトの作成
          - `RackBuilder#adapter` アダプタの設定
            - `Middleware.lookup_middleware` アダプタの特定
            - `RackBuilder::Handler#initialize` アダプタクラスオブジェクトの作成
    - `Connection#initialize_proxy`
- `Connection#get`
  - `Connection#run_request`
    - `Connection#build_request` リクエストオブジェクトを作成 (まだ送信していない)
      - `Request.create`
      - `Connection#proxy_for_request`
    - `RackBuilder#build_response`
      - `RackBuilder#build_env`
        - `Connection#build_exclusive_url`
        - `Env.new` (`Faraday::Env`)
      - `RackBuilder#app`
        - `RackBuilder#to_app`
          - `{アダプタ}#build` (`Adapter::NetHttp::Handler#build` => `RackBuilder::Handler#build`)
            - `Adapter::NetHttp#initialize`
          - `{ハンドラ}#build` (`Adapter::NetHttp::Handler#build` => `RackBuilder::Handler#build`)
            - `Request::UrlEncoded#initialize`
      - `{一番外側のハンドラ}#call` (`Request::UrlEncoded#call`)
        - `Request::UrlEncoded#match_content_type`
          - `NestedParamsEncoder.encode`
        - `{アダプタ}#call` (`Adapter::NetHttp#call`)
          - `Adapter#call`
          - `Adapter#connection`
            - `Adapter::NetHttp#build_connection`
              - `Adapter::NetHttp#net_http_connection`
              - `Adapter::NetHttp#configure_ssl`
              - `Adapter::NetHttp#configure_request`
            - `Adapter::NetHttp#perform_request`
              - `Env#stream_response?`
              - `Adapter::NetHttp#request_with_wrapped_block`
                - `Net::HTTP#start`
                  - `Net::HTTP#do_start`
                  - `Adapter::NetHttp#create_request`
                  - `Net::HTTP#request`
                    - `Adapter::NetHttp#save_http_response`
                      - `Adapter#save_response`
            - `#<Env>@response`を返す

## 気づいたこと
run_request- Rack風のインターフェースで任意のミドルウェアを追加できる
- Envオブジェクトで状態を一元管理している
- アダプタの差し替えができる、各アダプタはそれぞれ別gemとして管理されている
- `Faraday.new`でデフォルトヘッダとプロキシの設定、ハンドラとミドルウェアの設定までを行う

#### 追加機能
- TLSの設定 (`Adapter::NetHttp#configure_ssl`)
- タイムアウトの設定 (`Adapter::NetHttp#configure_request`)
- プロキシの設定 (`Connection#initialize_proxy`, `Connection#proxy_for_request`)
- ストリームレスポンス (`RequestOptions#on_data`)

| 代表的なミドルウェア            | 役割                                   |
| - | - |
| `Faraday::Request::UrlEncoded`  | bodyをx-www-form-urlencodedへ自動変換  |
| `Faraday::Request::Json`        | bodyをJSONへ変換、ヘッダも追加         |
| `Faraday::Multipart`関連        | multipart/form-dataを自動生成          |
| `Faraday::Request::OAuth`       | OAuth1署名を自動生成                   |
| `Faraday::Middleware::Retry`    | リトライ処理                           |
| `Faraday::Response::Logger`     | リクエスト・レスポンスログ出力         |
| `Faraday::Response::RaiseError` | statusに応じて例外発生                 |

## `Faraday.new`

```ruby
# (lib/faraday.rb)
# e.g. Faraday.new(url: "http://example.com").get("/index.html")

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
    memoized(:ssl) { self.class.options_for(:ssl).new }
    memoized(:builder_class) { RackBuilder } # => RackBuilder
  end
end

# Utils.deep_merge (lib/faraday/utils.rb)

def deep_merge(source, hash)
  deep_merge!(source.dup, hash) # => Utils.deep_merge!
end

# Utils.deep_merge! (lib/faraday/utils.rb)

# target = ConnectionOptions
# hash   = デフォルトでは空Hash
def deep_merge!(target, hash)
  hash.each do |key, value|
    target[key] = if value.is_a?(Hash) && (target[key].is_a?(Hash) || target[key].is_a?(Options))
                    deep_merge(target[key], value)
                  else
                    value
                  end
  end

  target # ConnectionOptions
end
```

## `Connection#initialize`

```ruby
# (lib/faraday/connection.rb)

# url     = String
# options = ConnectionOptions
def initialize(url = nil, options = nil)
  options = ConnectionOptions.from(options) # => Options.from

  # Options.from (lib/faraday/options.rb)
  # valueを元に新しいConnectionOptionsを作成する
  #
  #   def self.from(value)
  #     value ? new.update(value) : new
  #   end

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

  # プロキシのURLを特定した上でProxyOptionsでラップし@proxyに保存する
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

  # (lib/faraday.rb)
  # module Faraday
  #   self.default_adapter = :net_http
  #   self.default_adapter_options = {}
  # end
  adapter(Faraday.default_adapter, **Faraday.default_adapter_options) unless @adapter

  # => RackBuilder#adapter
end

# RackBuilder#request (lib/faraday/rack_builder.rb)

# key = :url_encoded
def request(key, ...)
  use_symbol(Faraday::Request, key, ...)
  # => Faraday::Request
  # => RackBuilder#use_symbol
end

# RackBuilder#use_symbol (lib/faraday/rack_builder.rb)

# mod = Faraday::Request
# key = :url_encoded
def use_symbol(mod, key, ...)
  handler = mod.lookup_middleware(key)
  # => MiddlewareRegistry#lookup_middleware
  # keyが:url_encodedの場合、handler = Faraday::Adapter::UrlEncoded
  use(handler, ...)
  # => RackBuilder#use
end

# MiddlewareRegistry#lookup_middleware (lib/faraday/middleware_registry.rb)

# key = :url_encodedなどのハンドラ、もしくは:net_httpなどのアダプタ
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

# RackBuilder#use (lib/faraday/rack_builder.rb))

# klass = ハンドラを表すシンボルかクラス
def use(klass, ...)
  if klass.is_a? Symbol
    use_symbol(Faraday::Middleware, klass, ...) # => RackBuilder#use_symbol
  else
    raise_if_locked # raise StackLocked, LOCK_ERR if locked? => RackBuilder#raise_if_locked
    raise_if_adapter(klass) # => RackBuilder#raise_if_adapter

    @handlers << self.class::Handler.new(klass, ...) # => RackBuilder::Handler#initialize
  end
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
  # この時点ではまだハンドラにラップしたklassからオブジェクトを生成しない
end

# RackBuilder#adapter (lib/faraday/rack_builder.rb)

# klass = :net_http (Faraday.default_adapter)
# args  = {}        (Faraday.default_adapter_options)
def adapter(klass = NO_ARGUMENT, *args, &block)
  return @adapter if klass == NO_ARGUMENT || klass.nil?

  klass = Faraday::Adapter.lookup_middleware(klass) if klass.is_a?(Symbol)
  # => Middleware.lookup_middleware
  # Faraday.default_adapterが:net_httpの場合、klass = Faraday::Adapter::NetHttp

  @adapter = self.class::Handler.new(klass, *args, &block) # => RackBuilder::Handler#initialize
end

# Connection#initialize_proxy (lib/faraday/connection.rb)

def initialize_proxy(url, options)
  @manual_proxy = !!options.proxy
  @proxy =
    if options.proxy
      ProxyOptions.from(options.proxy) # => Options.from
    else
      proxy_from_env(url) # => Connection#proxy_from_env
    end
end

# Connection#proxy_from_env (lib/faraday/connection.rb)

def proxy_from_env(url)
  return if Faraday.ignore_env_proxy

  uri = nil # この行不要では???

  case url
  when String
    uri = Utils.URI(url) # => Utils.URI

    # Utils.URI (lib/faraday/utils.rb)
    #
    #   def URI(url) # rubocop:disable Naming/MethodName
    #     if url.respond_to?(:host)
    #       url
    #     elsif url.respond_to?(:to_str)
    #       default_uri_parser.call(url)
    #     else
    #       raise ArgumentError, 'bad argument (expected URI object or URI string)'
    #     end
    #   end

    uri = if uri.host.nil?
            find_default_proxy # => Connection#find_default_proxy
          else
            URI.parse("#{uri.scheme}://#{uri.host}").find_proxy
          end
  when URI
    uri = url.find_proxy # URI::Generic#find_proxy
  when nil
    uri = find_default_proxy # => Connection#find_default_proxy
  end

  ProxyOptions.from(uri) if uri
end

# Connection#find_default_proxy

def find_default_proxy
  uri = ENV.fetch('http_proxy', nil)
  return unless uri && !uri.empty?

  uri = "http://#{uri}" unless uri.match?(/^http/i)
  uri
end
```

## `Connection#get`

```ruby
# (lib/faraday/connection.rb)
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

  # 呼び出し側 (Connection)
  #   run_request(:#{method}, url, nil, headers) do |request|
  #     request.params.update(params) if params
  #     yield request if block_given?
  #   end

  request = build_request(method) do |req| # => Connection#build_request
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

    def self.create(request_method) # request_method = :get など
      new(request_method).tap do |request|
        yield(request) if block_given?
      end
    end

    # ...
  end
end

# Connection#proxy_for_request (lib/faraday/connection.rb)

def proxy_for_request(url)
  return proxy if @manual_proxy # proxy = @proxy デフォルトではinitialize時の#initialize_proxyの返り値

  if url && Utils.URI(url).absolute?
    proxy_from_env(url)
  else
    proxy
  end
end

# RackBuilder#build_response (lib/faraday/rack_builder.rb)

def build_response(connection, request)
  env = build_env(connection, request)
  # => RackBuilder#build_env

  app.call(env)
  # => RackBuilder#app
  # => {一番外側のハンドラ}#call (Request::UrlEncoded#call)
end

# RackBuilder#build_env (lib/faraday/rack_builder.rb)

def build_env(connection, request)
  # リクエストパスとConnectionの持つurl_prefixを組み合わせて単一のURI オブジェクトに正規化する
  exclusive_url = connection.build_exclusive_url( # => Connection#build_exclusive_url
    request.path,
    request.params,
    request.options.params_encoder
  )

  Env.new( # => Faraday::Env
    request.http_method,
    request.body,
    exclusive_url,
    request.options,
    request.headers,
    connection.ssl,
    connection.parallel_manager
  )
end

# Connection#build_exclusive_url (lib/faraday/connection.rb)

def build_exclusive_url(url = nil, params = nil, params_encoder = nil)
  url  = nil if url.respond_to?(:empty?) && url.empty?
  base = url_prefix.dup # url_prefix = initialize時にself.url_prefix = url || 'http:/'

  if url && !base.path.end_with?('/')
    base.path = "#{base.path}/" # ensure trailing slash
  end

  # Ensure relative url will be parsed correctly (such as `service:search` )
  url = "./#{url}" if url.respond_to?(:start_with?) && !url.start_with?('http://', 'https://', '/', './', '../')
  uri = url ? base + url : base

  if params
    uri.query = params.to_query(params_encoder || options.params_encoder)
  end

  uri.query = nil if uri.query && uri.query.empty?
  uri
end

# Faraday::Env (lib/faraday/options/env.rb)

Env = Options.new(:method, :request_body, :url, :request, :request_headers, :ssl, :parallel_manager, :params,
                  :response, :response_headers, :status, :reason_phrase, :response_body) do

  const_set(:ContentLength,       'Content-Length')
  const_set(:StatusesWithoutBody, Set.new([204, 304]))
  const_set(:SuccessfulStatuses,  (200..299))
  const_set(:MethodsWithBodies,   Set.new(Faraday::METHODS_WITH_BODY.map(&:to_sym)))

  options request: RequestOptions,
          request_headers: Utils::Headers,
          response_headers: Utils::Headers

  extend Forwardable

  def_delegators :request, :params_encoder

  # ...
end

# RackBuilder#app (lib/faraday/rack_builder.rb)

def app
  @app ||= begin
    # ここまで追加したハンドラをfreeze
    lock! # @handlers.freeze => RackBuilder#lock!
    # アダプタがセットされていなければ例外発生
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

# Rackっぽいアーキテクチャになっている
def to_app
  # @handlers = [Faraday::Request::UrlEncoded (Faraday::RackBuilder::Handle) ]
  #   - RackBuilder#initialize時に空配列で初期化される
  #   - RackBuilder::Handler#insert, RackBuilder::Handler#delete, ...などで操作される
  #   - @handlersに値を追加するのはRackBuilder#use, RackBuilder#insert
  # @adapter = Faraday::Adapter::NetHttp (Faraday::RackBuilder::Handler)
  #   - RackBuilder#initialize時にnilで初期化される
  #   - RackBuilder#adapterで値が追加される

  builded_adapter = @adapter.build # => Adapter::NetHttp::Handler#build (RackBuilder::Handler#build)

  # ハンドラがアダプタをラップする構造を返す
  @handlers.reverse.inject(builded_adapter) do |app, handler|
    handler.build(app) # => Request::UrlEncoded#build (RackBuilder::Handler#build)
  end
end

# RackBuilder::Handler#build (lib/faraday/rack_builder.rb)

def build(app = nil)
  # ハンドラでラップしたクラスのオブジェクトを生成する
  klass.new(app, *@args, &@block)
  # => ({アダプタ}.buildの場合) Adapter::NetHttp#initialize (appはnil)
  # => ({ハンドラ}.buildの場合) Request::UrlEncoded#initialize (appは#<Adapter::NetHttp>)
end

# Request::UrlEncoded#call (lib/faraday/request/url_encoded.rb)

def call(env)
  match_content_type(env) do |data| # => Request::UrlEncoded#match_content_type
    # data = env.body
    params = Faraday::Utils::ParamsHash[data]
    # key=value&... 形式の文字列にする
    env.body = params.to_query(env.params_encoder) # => Utils::ParamsHash.to_query

    # Utils::ParamsHash.to_query (lib/faraday/utils/params_hash.rb)
    #
    #   def to_query(encoder = nil)
    #     (encoder || Utils.default_params_encoder).encode(self)
    #     # Utils.default_params_encoder = NestedParamsEncoder
    #     # => NestedParamsEncoder.encode
    #   end
  end

  # @app = #<Faraday::Adapter::NetHttp>
  # env  = #<Faraday::Env>
  @app.call env # => Adapter::NetHttp#call
end

# Request::UrlEncoded#match_content_type (lib/faraday/request/url_encoded.rb)

def match_content_type(env)
  # bodyがあり、かつContent-Typeが未設定かapplication/x-www-form-urlencodedの場合はreturn
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

  #   class << self
  #     attr_accessor :mime_type
  #   end
  #   self.mime_type = 'application/x-www-form-urlencoded'

  return if env.body.respond_to?(:to_str) || env.body.respond_to?(:read)

  yield(env.body)
end

# NestedParamsEncoder#encode (lib/faraday/encoders/nested_params_encoder.rb)

def encode(params)
  return nil if params.nil?

  unless params.is_a?(Array)
    unless params.respond_to?(:to_hash)
      raise TypeError, "Can't convert #{params.class} into Hash."
    end

    params = params.to_hash
    params = params.map do |key, value|
      key = key.to_s if key.is_a?(Symbol)
      [key, value]
    end

    # Only to be used for non-Array inputs. Arrays should preserve order.
    params.sort! if @sort_params
  end

  # The params have form [['key1', 'value1'], ['key2', 'value2']].
  buffer = +''
  params.each do |parent, value|
    encoded_parent = escape(parent)
    buffer << "#{encode_pair(encoded_parent, value)}&"
  end
  buffer.chop
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

      # Adapter::NetHttp#initialize (lib/faraday/adapter/net_http.rb)

      def initialize(app = nil, opts = {}, &block)
        @ssl_cert_store = nil
        super(app, opts, &block) # => Adapter#initialize

        # Adapter#initialize (faraday: lib/faraday/adapter.rb)
        #
        #  def initialize(_app = nil, opts = {}, &block)
        #    @app = lambda(&:response)
        #    @connection_options = opts
        #    @config_block = block
        #  end
      end

      # Adapter::NetHttp#call (lib/faraday/adapter/net_http.rb)

      def call(env)
        super

        # Adapter#call (faraday: lib/faraday/adapter.rb)
        #
        #   def call(env)
        #     env.clear_body if env.needs_body?
        #     env.response = Response.new # => Response#initialize
        #   end

        connection(env) do |http| # => Adapter#connection
          # http = #<Net::HTTP>
          perform_request(http, env) # => Adapter::NetHttp#perform_request
        rescue *NET_HTTP_EXCEPTIONS => e
          raise Faraday::SSLError, e if defined?(OpenSSL) && e.is_a?(OpenSSL::SSL::SSLError)
          raise Faraday::ConnectionFailed, e
        end

        # @app = #<Proc:(&:response) (lambda)> (Adapter#initialize)
        # env  = #<Faraday::Env>
        # ここまででレスポンスから得た値がenvにセットされている
        @app.call env # => Envの@responseとして #<Faraday::Response> を返す
      rescue Timeout::Error, Errno::ETIMEDOUT => e
        raise Faraday::TimeoutError, e
      end
    end
  end
end

# Adapter#connection (faraday: lib/faraday/adapter.rb)

def connection(env)
  conn = build_connection(env) # => Adapter::NetHttp#build_connection
  # conn = #<Net::HTTP>

  return conn unless block_given?

  yield conn

  # 呼び出し側
  #   connection(env) do |http|
  #     perform_request(http, env)
  #   end
end

# Adapter::NetHttp#build_connection (lib/faraday/adapter/net_http.rb)

def build_connection(env)
  net_http_connection(env).tap do |http| # => Adapter::NetHttp#net_http_connection
    configure_ssl(http, env[:ssl]) if env[:url].scheme == 'https' && env[:ssl] # => Adapter::NetHttp#configure_ssl
    configure_request(http, env[:request]) # => Adapter::NetHttp#configure_request
  end
end

# Adapter::NetHttp#net_http_connection (lib/faraday/adapter/net_http.rb)

def net_http_connection(env)
  proxy = env[:request][:proxy]
  port = env[:url].port || (env[:url].scheme == 'https' ? 443 : 80)

  if proxy
    Net::HTTP.new(
      env[:url].hostname,
      port,
      proxy[:uri].hostname,
      proxy[:uri].port,
      proxy[:user],
      proxy[:password],
      nil,
      proxy[:uri].scheme == 'https'
    )
  else
    Net::HTTP.new(
      env[:url].hostname,
      port,
      nil
    )
  end
end

# Adapter::NetHttp#configure_ssl (lib/faraday/adapter/net_http.rb)

def configure_ssl(http, ssl)
  http.use_ssl = true if http.respond_to?(:use_ssl=)

  http.verify_mode = ssl_verify_mode(ssl)i # => Adapter::NetHttp#ssl_verify_mode
  http.cert_store = ssl_cert_store(ssl) # => Adapter::NetHttp#ssl_cert_store

  cert, *extra_chain_cert = ssl[:client_cert]
  http.cert               = cert             if cert
  http.extra_chain_cert   = extra_chain_cert if extra_chain_cert.any?

  http.key             = ssl[:client_key]      if ssl[:client_key]
  http.ca_file         = ssl[:ca_file]         if ssl[:ca_file]
  http.ca_path         = ssl[:ca_path]         if ssl[:ca_path]
  http.verify_depth    = ssl[:verify_depth]    if ssl[:verify_depth]
  http.ssl_version     = ssl[:version]         if ssl[:version]
  http.min_version     = ssl[:min_version]     if ssl[:min_version]
  http.max_version     = ssl[:max_version]     if ssl[:max_version]
  http.verify_hostname = ssl[:verify_hostname] if verify_hostname_enabled?(http, ssl)
  http.ciphers         = ssl[:ciphers]         if ssl[:ciphers]
end

# Adapter::NetHttp#configure_request (lib/faraday/adapter/net_http.rb)

def configure_request(http, req)
  if (sec = request_timeout(:read, req))
    http.read_timeout = sec
  end

  if (sec = http.respond_to?(:write_timeout=) &&
    request_timeout(:write, req))
    http.write_timeout = sec
  end

  if (sec = request_timeout(:open, req))
    http.open_timeout = sec
  end

  # Only set if Net::Http supports it, since Ruby 2.5.
  http.max_retries = 0 if http.respond_to?(:max_retries=)

  @config_block&.call(http)
end

# Adapter::NetHttp#perform_request (lib/faraday/adapter/net_http.rb)

# http = #<Net::HTTP example.com:80 open=false>
# env  = #<Faraday::Env
#          @method=:get
#          @url=#<URI::HTTP http://example.com/index.html>
#          @request=#<Faraday::RequestOptions (empty)>
#          @request_headers={"User-Agent" => "Faraday v2.12.2"}
#          @ssl=#<Faraday::SSLOptions (empty)>
#          @response=#<Faraday::Response:0x00000001055dbf50
#          @on_complete_callbacks=[]>

def perform_request(http, env)
  if env.stream_response? # => Env#stream_response?

    http_response = env.stream_response do |&on_data|
      request_with_wrapped_block(http, env, &on_data) # => Adapter::NetHttp#request_with_wrapped_block
    end

    http_response.body = nil
  else
    http_response = request_with_wrapped_block(http, env) # => Adapter::NetHttp#request_with_wrapped_block
  end

  env.response_body = encoded_body(http_response)
  env.response.finish(env) # => Response#finish
  http_response
end

# Env#stream_response? (lib/faraday/options/env.rb)

def stream_response?
  request.stream_response? # => RequestOptions#stream_response?
end

# RequestOptions#stream_response? (lib/faraday/options/request_options.rb)

RequestOptions = Options.new(
  :params_encoder, :proxy, :bind,
  :timeout, :open_timeout, :read_timeout, :write_timeout,
  :boundary, :oauth, :context, :on_data
)

def stream_response?
  on_data.is_a?(Proc)
end

# Adapter::NetHttp#request_with_wrapped_block (lib/faraday/adapter/net_http.rb)

def request_with_wrapped_block(http, env, &block)
  http.start do |opened_http| # => Net::HTTP#start (Net::HTTP#do_start -> httpをブロック変数としてyield)
    opened_http.request(create_request(env)) do |response| # 実際のHTTPリクエストを送信
      # => Net::HTTP#request
      # => (引数) Adapter::NetHttp#create_request

      # response = Net::HTTP#transport_requestの返り値 #<Net::HTTPOK 200 OK readbody=false> など
      # Net::HTTPResponseをenvでラップする
      save_http_response(env, response) # => Adapter::NetHttp#save_http_response

      response.read_body(&block) if block_given?
    end
  end
end

# Adapter::NetHttp#create_request (lib/faraday/adapter/net_http.rb)

def create_request(env)
  request = Net::HTTPGenericRequest.new( # => Net::HTTPGenericRequest#initialize
    env[:method].to_s.upcase, # request method
    !!env[:body], # is there request body
    env[:method] != :head, # is there response body
    env[:url].request_uri, # request uri path
    env[:request_headers] # request headers
  )

  if env[:body].respond_to?(:read)
    request.body_stream = env[:body]
  else
    request.body = env[:body]
  end

  request
end

# Adapter::NetHttp#save_http_response (lib/faraday/adapter/net_http.rb)

def save_http_response(env, http_response)
  save_response( # => Adapter#save_response
    env,
    http_response.code.to_i,
    nil,
    nil,
    http_response.message,
    finished: false
  ) do |response_headers| # #<Utils::Headers>
    http_response.each_header do |key, value| # レスポンスヘッダの値を#<Utils::Headers>にセット
      response_headers[key] = value
    end
  end
end

# Adapter#save_response (lib/faraday/adapter.rb)

def save_response(env, status, body, headers = nil, reason_phrase = nil, finished: true)
  env.status = status
  env.body = body
  env.reason_phrase = reason_phrase&.to_s&.strip

  env.response_headers = Utils::Headers.new.tap do |response_headers|
    response_headers.update headers unless headers.nil?
    yield(response_headers) if block_given?
  end

  env.response.finish(env) unless env.parallel? || !finished # => Response#finish
  env.response
end

# Response#finish (lib/faraday/response.rb)

def finish(env)
  raise 'response already finished' if finished?

  @env = env.is_a?(Env) ? env : Env.from(env)
  @on_complete_callbacks.each { |callback| callback.call(@env) }
  self
end
```

### `Response#initialize`

```ruby
# (lib/faraday/response.rb)

def initialize(env = nil)
   @env = Env.from(env) if env
   @on_complete_callbacks = []
 end
```
