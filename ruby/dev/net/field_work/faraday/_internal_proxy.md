# faraday 現地調査: プロキシ編 (202512時点)
## `Faraday.new`で指定 / 環境変数で指定
- `Faraday.new`にproxyキーワードを指定する

```ruby
connection = Faraday.new("https://example.com", proxy: "http://proxy.example.com") # => Faraday.new
connection.get
```

```ruby
# Faraday.new (lib/faraday.rb)

def new(url = nil, options = {}, &block)
  # 指定のキーワードをdefault_connection_optionsとマージしてConnectionOptionsを返す
  options = Utils.deep_merge(default_connection_options, options)
  # => Faraday.default_connection_options

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

# Connection#initialize (lib/faraday/connection.rb)

# url     = String
# options = ConnectionOptions
def initialize(url = nil, options = nil)
  options = ConnectionOptions.from(options) # => Options.from

  # Options.from (lib/faraday/options.rb)
  # 渡されたvalue (ConnectionOptions) を元に新しいConnectionOptionsを作成する
  #
  #   def self.from(value)
  #     value ? new.update(value) : new
  #   end

  # --- この辺りはあまり関係ない ---
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

  # connectionoptions#proxyの指定があるかないか
  # connection#url_prefix= / connection#proxy_for_requestから参照される
  @manual_proxy = nil

  @builder = options.builder || begin
    # pass an empty block to Builder so it doesn't assume default middleware
    options.new_builder(block_given? ? proc { |b| } : nil) # => ConnectionOptions#new_builder
  end

  self.url_prefix = url || 'http:/'

  @params.update(options.params)   if options.params
  @headers.update(options.headers) if options.headers
  # --- この辺りはあまり関係ない ---

  # Faraday.newにproxyキーワードを渡している場合
  # プロキシのURLを特定した上でProxyOptionsでラップし@proxyに保存する
  initialize_proxy(url, options) # => Connection#initialize_proxy

  # Faraday.newブロック内部でproxyを指定している場合
  yield(self) if block_given? # => Connection#proxy=

  @headers[:user_agent] ||= USER_AGENT
end

# Connection#initialize_proxy (lib/faraday/connection.rb)

def initialize_proxy(url, options)
  # ConnectionOptions#proxyの指定があるかないか
  # Connection#url_prefix= / Connection#proxy_for_requestから参照される
  @manual_proxy = !!options.proxy

  @proxy =
    if options.proxy # => ConnectionOptions#proxy Faraday.newにproxyキーワードを渡している場合はこちら
      ProxyOptions.from(options.proxy) # => ProxyOptions.from
    else
      proxy_from_env(url) # => Connection#proxy_from_env 環境変数によるプロキシの設定を取得する (あれば)
    end
end

# ProxyOptions.from (lib/faraday/options/proxy_options.rb)

ProxyOptions = Options.new(:uri, :user, :password) do
  extend Forwardable
  def_delegators :uri, :scheme, :scheme=, :host, :host=, :port, :port=,
                 :path, :path=

  def self.from(value) # 値を受け取って (デフォルトでは) URIオブジェクトにしてProxyOptionsを更新する
    case value
    when '' then  value = nil
    when String
      value = "http://#{value}" unless value.include?('://')
      value = { uri: Utils.URI(value) } # => Utils.URI
    when URI then  value = { uri: value }
    when Hash, Options
      if (uri = value.delete(:uri))
        value[:uri] = Utils.URI(uri)
      end
    end

    super(value) # => Options#from
  end

  memoized(:user) { uri&.user && Utils.unescape(uri.user) }
  memoized(:password) { uri&.password && Utils.unescape(uri.password) }
end

# Utils.URI (/lib/faraday/utils.rb)

def URI(url) # rubocop:disable Naming/MethodName
  if url.respond_to?(:host)
    url
  elsif url.respond_to?(:to_str)
    default_uri_parser.call(url) # => Utils.default_uri_parser
  else
    raise ArgumentError, 'bad argument (expected URI object or URI string)'
  end
end

# Utils.default_uri_parser (lib/faraday/utils.rb)

def default_uri_parser
  @default_uri_parser ||= Kernel.method(:URI) # Utils.default_uri_parser=で差し替え可能
end

# Connection#proxy_from_env (lib/faraday/connection.rb)

def proxy_from_env(url)
  return if Faraday.ignore_env_proxy # 環境変数によるプロキシの設定を無視する

  uri = nil # この行不要では???

  case url
  when String
    uri = Utils.URI(url) # => Utils.URI
    uri = if uri.host.nil?
            # 環境変数http_proxyを直接取得しようとする
            find_default_proxy # => Connection#find_default_proxy
          else
            # URI::Generic#find_proxyを使って環境変数http_proxy / https_proxyからプロキシを取得する
            URI.parse("#{uri.scheme}://#{uri.host}").find_proxy # => URI::Generic#find_proxy
          end
  when URI
    # URI::Generic#find_proxyを使って環境変数http_proxy / https_proxyからプロキシを取得する
    uri = url.find_proxy # URI::Generic#find_proxy
  when nil
    # 環境変数http_proxyを直接取得しようとする
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

## `Faraday::Connection#proxy=`で外部指定する

```ruby
connection = Faraday.new("https://example.com")
connection.proxy = { uri: "http://proxy.example.com:8080" }
connection.get

# Faraday.newブロック内部でConnection#proxy=

connection = Faraday.new("https://example.com") {
  it.proxy = "http://proxy.example.com"
}
connection.get
```



```ruby
# Connection#proxy= (lib/faraday/connection.rb)

def proxy=(new_value)
  # connectionoptions#proxyの指定があるかないか
  # connection#url_prefix= / connection#proxy_for_requestから参照される
  @manual_proxy = true

  # @proxyに値を設定する
  @proxy = new_value ? ProxyOptions.from(new_value) : nil
end
```

## 設定されたプロキシを利用する

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

METHODS = Set.new %i[get post put delete head patch options trace]

# Connection#run_request (lib/faraday/connection.rb)

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
    # WIP プロキシがreq.options.proxyに格納された後どう使われるかを確認する

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

# Connection#proxy_for_request (lib/faraday/connection.rb)

def proxy_for_request(url)
  # @manual_proxy = Faraday.newにproxyキーワードを渡すか、Connection#proxy=を明示的に呼び出した場合trueになっている
  # プロキシを明示的に呼び出した場合、指定された値を持つProxyOptionsを返す
  return proxy if @manual_proxy # attr_reader :proxy

  # FaradayではFaradayインスタンスを初期化する時とgetなどのメソッドを経由してConnection#run_requestを呼び出す時
  # それぞれURLを指定できる。
  # Faradayインスタンスを初期化する時に渡されたURLを元に#proxy_from_envで設定するプロキシを初期値とし、
  # #run_requestを呼び出す時に渡されたURLがある場合はそれを元に#proxy_from_envで設定するプロキシを利用する
  if url && Utils.URI(url).absolute?
    proxy_from_env(url)
  else
    proxy
  end
end
```
