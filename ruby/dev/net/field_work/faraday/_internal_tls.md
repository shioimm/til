# faraday 現地調査: TLS編 (202512時点)
## 気づいたこと
- `env[:url].scheme == 'https' && env[:ssl]`の場合、自動的にHTTPSで接続する
  - `env[:url].scheme`は接続先のURLから取得する
  - `env[:ssl]`は`ConnectionOptions.from`が呼ばれる経路ではつねにtruthy
- 初期設定をまとめて明示することができる、テンポラリに設定を変更することもできる
- `verify_mode`を明示的に指定するか、`verify`オプションを指定しない場合verify_modeが`OpenSSL::SSL::VERIFY_NONE`
- 証明書ストアを明示していなくてもシステムに組み込まれた証明書ストアを使う

### 指定できない設定
- `verify_callback=` (`OpenSSL::X509::Store#verify_callback=`)
- `verify_hostname=` (?)

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
store = OpenSSL::X509::Store.new
store.set_default_paths

connection = Faraday.new("https://example.com") { |conn|
  conn.ssl.verify = true # OpenSSL::SSL:VERIFY_PEER
  conn.ssl.ca_file = "/etc/ssl/certs/ca-certificates.crt"
  conn.ssl.ca_path = "/etc/ssl/certs"
  # 中間証明書は配列でclient_certに渡す
  conn.ssl.client_cert = OpenSSL::X509::Certificate.new(File.read("client.crt"))
  conn.ssl.client_key  = OpenSSL::PKey::RSA.new(File.read("client.key"))
  conn.ssl.cert_store = store
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
    :request,
    :proxy,
    :ssl,
    :builder,
    :url,
    :parallel_manager,
    :params,
    :headers,
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
    :verify,          # サーバ証明書を検証するかどうか (指定しないとVERIFY_NONE)
    :verify_hostname, # 証明書のCN/SANと接続先ホスト名が一致するか (Ruby 2.4以上/OpenSSL 1.1以上で通常true)
    :verify_mode,     # 検証モード
    :verify_depth,    # 証明書チェーンの最大長
    :ca_file,         # CA証明書ファイル
    :ca_path,         # CA証明書ファイル (ディレクトリを指定)
    :cert_store,      # 詳細なCA検証ロジック (OpenSSL::X509::Store)
    :client_cert,     # クライアント証明書 (配列で中間証明書の指定も可能)
    :certificate,     # client_cert
    :client_key,      # クライアント証明書に対応する秘密鍵
    :private_key,     # client_key
    :version,         # TLSバージョン
    :min_version,     # TLSバージョン (最低)
    :max_version,     # TLSバージョン (最高)
    :ciphers          # 暗号スイート
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

  # 上段で options = ConnectionOptions.from(options) しているため、つねに@ssl = #<SSLOptions>
  # 宛先のスキームに関わらず、指定されていない場合は #<Faraday::SSLOptions (empty)> になる
  @ssl = options.ssl

  @default_parallel_manager = options.parallel_manager
  @manual_proxy = nil

  @builder = options.builder || begin
    # pass an empty block to Builder so it doesn't assume default middleware
    options.new_builder(block_given? ? proc { |b| } : nil) # => ConnectionOptions#new_builder
  end

  # url_prefixに指定のURLを保存する
  self.url_prefix = url || 'http:/' # => Connection#url_prefix=

  @params.update(options.params)   if options.params
  @headers.update(options.headers) if options.headers

  initialize_proxy(url, options) # => Connection#initialize_proxy

  # ブロックの中でアクセスしているsslは#<Connection>自身の@ssl (#<SSLOptions>)
  yield(self) if block_given?
  # #<Connection>のoptions経由で@ssl (#<SSLOptions>) に設定を保存できる

  @headers[:user_agent] ||= USER_AGENT
end

# Connection#url_prefix= (lib/faraday/connection.rb)

def_delegators :url_prefix, :scheme, :scheme=, :host, :host=, :port, :port=
def_delegator :url_prefix, :path, :path_prefix

def url_prefix=(url, encoder = nil)
  # 初期化時に渡された文字列urlをURIにする
  uri = @url_prefix = Utils.URI(url) # => Utils.URI

  self.path_prefix = uri.path # Connection#path_prefix=

  params.merge_query(uri.query, encoder) # => ParamsHash#merge_query
  uri.query = nil

  # ユーザー／パスワードが指定されている場合はURIにセット
  with_uri_credentials(uri) do |user, password|
    set_basic_auth(user, password)
    uri.user = uri.password = nil
  end

  # 環境変数からプロキシをセット
  @proxy = proxy_from_env(url) unless @manual_proxy
end

# Utils.URI (lib/faraday/utils.rb)

def URI(url) # rubocop:disable Naming/MethodName
  if url.respond_to?(:host)
    url
  elsif url.respond_to?(:to_str)
    default_uri_parser.call(url) # => Utils.default_uri_parser
  else
    raise ArgumentError, 'bad argument (expected URI object or URI string)'
  end
en

# Utils.default_uri_parser (lib/faraday/utils.rb)d

def default_uri_parser
  @default_uri_parser ||= Kernel.method(:URI)
end

# Connection#path_prefix= (lib/faraday/connection.rb)

def path_prefix=(value)
  url_prefix.path =
    if value
      value = "/#{value}" unless value[0, 1] == '/'
      value
    end
end

# ParamsHash#merge_query (lib/faraday/utils/params_hash.rb)

def merge_query(query, encoder = nil)
  return self unless query && !query.empty?

  update((encoder || Utils.default_params_encoder).decode(query))
end

# Connection#with_uri_credentials (lib/faraday/connection.rb)

def with_uri_credentials(uri)
  return unless uri.user && uri.password

  yield(Utils.unescape(uri.user), Utils.unescape(uri.password))
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
    request.http_method,        # :method
    request.body,               # :request_body
    exclusive_url,              # :url
    request.options,            # :request
    request.headers,            # :request_headers
    connection.ssl,             # :ssl 初期化時に#<Connection>に明示した設定 (#<SSLOptions)
    connection.parallel_manager # :parallel_manager
  )
end

# Connection#build_exclusive_url (lib/faraday/connection.rb)

def build_exclusive_url(url = nil, params = nil, params_encoder = nil)
  url  = nil if url.respond_to?(:empty?) && url.empty?

  # url_prefix = initialize時にself.url_prefix = url || 'http:/' した#<URI>
  base = url_prefix.dup

  # trailing slashを追加
  if url && !base.path.end_with?('/')
    base.path = "#{base.path}/" # ensure trailing slash
  end

  # 壊れた相対パスを正しい相対パスに修正
  # Ensure relative url will be parsed correctly (such as `service:search` )
  url = "./#{url}" if url.respond_to?(:start_with?) && !url.start_with?('http://', 'https://', '/', './', '../')
  uri = url ? base + url : base

  if params
    uri.query = params.to_query(params_encoder || options.params_encoder)
  end

  uri.query = nil if uri.query && uri.query.empty?
  uri
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
end

# Request::UrlEncoded#call (lib/faraday/request/url_encoded.rb)

def call(env)
  match_content_type(env) do |data| # => Request::UrlEncoded#match_content_type
    # data = env.body
    params = Faraday::Utils::ParamsHash[data]
    # key=value&... 形式の文字列にする
    env.body = params.to_query(env.params_encoder) # => Utils::ParamsHash.to_query
  end

  # @app = #<Faraday::Adapter::NetHttp>
  # env  = #<Faraday::Env>
  @app.call env # => Adapter::NetHttp#call
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

# Adapter#connection (faraday: lib/faraday/adapter.rb)

def connection(env)
  conn = build_connection(env) # => Adapter::NetHttp#build_connection
  # conn = #<Net::HTTP>

  return conn unless block_given?

  yield conn

  # 呼び出し側
c  #   connection(env) do |http|
  #     perform_request(http, env)
  #   end
end

# Adapter::NetHttp#build_connection (lib/faraday/adapter/net_http.rb)

def build_connection(env)
  net_http_connection(env).tap do |http| # => Adapter::NetHttp#net_http_connection
    if env[:url].scheme == 'https' && env[:ssl]
      configure_ssl(http, env[:ssl]) # => Adapter::NetHttp#configure_ssl
    end

    configure_request(http, env[:request]) # => Adapter::NetHttp#configure_request
  end
end

# Adapter::NetHttp#net_http_connection (lib/faraday/adapter/net_http.rb)

def net_http_connection(env)
  proxy = env[:request][:proxy]

  # 接続先ポートを取得。env[:url]はURIオブジェクト
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

# http = #<Net::HTTP>
# ssl  = env[:ssl] 初期化時に#<Connection>に明示した設定 (#<SSLOptions)
def configure_ssl(http, ssl)
  # アダプタが交換できるためrespond_to?している気がする
  http.use_ssl = true if http.respond_to?(:use_ssl=)

  # http.verify_mode = 明示したモード or VERIFY_PEER or VERIFY_NONE
  http.verify_mode = ssl_verify_mode(ssl) # => Adapter::NetHttp#ssl_verify_mode

  # サーバ証明書の検証
  http.cert_store = ssl_cert_store(ssl) # => Adapter::NetHttp#ssl_cert_store # 最優先
  http.ca_file    = ssl[:ca_file] if ssl[:ca_file]
  http.ca_path    = ssl[:ca_path] if ssl[:ca_path]

  # クライアント証明書の設定
  cert, *extra_chain_cert = ssl[:client_cert]
  http.cert             = cert               if cert # 公開鍵証明書
  http.key              = ssl[:client_key]   if ssl[:client_key] # 秘密鍵
  http.extra_chain_cert = extra_chain_cert   if extra_chain_cert.any? # 中間証明書チェーン
  http.verify_depth     = ssl[:verify_depth] if ssl[:verify_depth] # 証明書チェーン上の検証する最大の深さ

  # バージョンの指定
  http.ssl_version = ssl[:version]     if ssl[:version] # 非推奨
  http.min_version = ssl[:min_version] if ssl[:min_version] # 最小バージョン
  http.max_version = ssl[:max_version] if ssl[:max_version] # 最大バージョン

  # OpenSSLには存在しない?
  http.verify_hostname = ssl[:verify_hostname] if verify_hostname_enabled?(http, ssl)
  # => Adapter::NetHttp#verify_hostname_enabled?

  # 利用可能な共通鍵暗号
  http.ciphers = ssl[:ciphers] if ssl[:ciphers]
end

# Adapter::NetHttp#ssl_verify_mode (lib/faraday/adapter/net_http.rb)

def ssl_verify_mode(ssl)
  # 明示したverify_mode、もしくはOpenSSL::SSL::VERIFY_PEER、そうでなければOpenSSL::SSL::VERIFY_NONE
  ssl[:verify_mode] || begin
    if ssl.fetch(:verify, true)
      OpenSSL::SSL::VERIFY_PEER
    else
      OpenSSL::SSL::VERIFY_NONE
    end
  end
end

# Adapter::NetHttp#ssl_cert_store (lib/faraday/adapter/net_http.rb)

def ssl_cert_store(ssl)
  # 信頼しているCA証明書を含む証明書ストアが明示されている場合
  return ssl[:cert_store] if ssl[:cert_store]

  # 証明書ストアが明示されていない場合
  # httpartyのConnectionAdapter.default_cert_storeを同じくシステムに組込まれている証明書を読み込む
  # Use the default cert store by default, i.e. system ca certs
  @ssl_cert_store ||= OpenSSL::X509::Store.new.tap(&:set_default_paths) # => OpenSSL::X509::Store#set_default_paths
end

# Adapter::NetHttp#verify_hostname_enabled? (lib/faraday/adapter/net_http.rb)

def verify_hostname_enabled?(http, ssl)
  http.respond_to?(:verify_hostname=) && ssl.key?(:verify_hostname)
end
```
