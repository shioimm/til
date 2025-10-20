# httpx 現地調査 (202510時点)
https://gitlab.com/os85/httpx

```ruby
# (lib/httpx/chainable.rb)

module HTTPX
  module Chainable
    %w[head get post put delete trace options connect patch].each do |meth|
      class_eval(<<-MOD, __FILE__, __LINE__ + 1)
        def #{meth}(*uri, **options)                # def get(*uri, **options)
          request("#{meth.upcase}", uri, **options) #   request("GET", uri, **options)
        end                                         # end
      MOD
    end

    def request(*args, **options)
      # default_options = @options || Session.default_options (Session.default_optionsはOptions.new)
      #   #<HTTPX::Options:0x000000011bf841b8
      #     @max_requests=Infinity, @debug_level=1, @ssl={},
      #     @http2_settings={settings_enable_push: 0},
      #     @fallback_protocol="http/1.1",
      #     @supported_compression_formats=["gzip", "deflate"],
      #     @decompress_response_body=true, @compress_request_body=true,
      #     @timeout={
      #       connect_timeout: 60, settings_timeout: 10, close_handshake_timeout: 10,
      #       operation_timeout: nil, keep_alive_timeout: 20, read_timeout: 60, write_timeout: 60,
      #       request_timeout: nil
      #     },
      #     @headers_class=#<Class:0x0000000100beb0f8>, @headers={},
      #     @window_size=16384, @buffer_size=16384, @body_threshold_size=114688,
      #     @request_class=#<Class:0x0000000100beaf18>, @response_class=#<Class:0x0000000100beadd8>,
      #     @request_body_class=#<Class:0x0000000100beac98>, @response_body_class=#<Class:0x0000000100beab58>,
      #     @pool_class=#<Class:0x0000000100beaa18>, @pool_options={}, @connection_class=#<Class:0x0000000100bea8d8>,
      #     @options_class=#<Class:0x0000000100bea798>, @persistent=false,
      #     @resolver_class=:native, @resolver_options={cache: true},
      #     @ip_families=[30, 2]>

      branch(default_options).request(*args, **options)
    end

    def branch(options, &blk)
      # self = HTTPX
      return self.class.new(options, &blk) if is_a?(S)

      Session.new(options, &blk)
    end
  end

  extend Chainable
end
```

## `Session#request`

```ruby
# (lib/httpx/session.rb)

module HTTPX
  class Session
    include Loggable
    include Chainable

    def initialize(options = EMPTY_HASH, &blk)
      @options = self.class.default_options.merge(options)
      @responses = {}
      @persistent = @options.persistent
      @pool = @options.pool_class.new(@options.pool_options)
      @wrapped = false
      @closing = false
      wrap(&blk) if blk
    end

    # args   = ["GET", ["https://example.com"]]
    # params = {}
    def request(*args, **params)
      raise ArgumentError, "must perform at least one request" if args.empty?

      requests = args.first.is_a?(Request) ? args : build_requests(*args, params) # Session#build_requests

      # argsの宛先が複数ある場合は配列でHTTPX::Requestを持つ
      # requests = [
      #   #<HTTPX::Request:216 GET https://example.com
      #     @headers={
      #       "user-agent" => ["httpx.rb/1.4.3"],
      #       "accept" => ["*/*"],
      #       "accept-encoding" => ["gzip", "deflate"]
      #     }
      #     @body=>
      # ]

      responses = send_requests(*requests) # => Session#send_requests
      return responses.first if responses.size == 1

      responses
    end
```

### `Session#build_requests`

```ruby
# (lib/httpx/session.rb)

def build_requests(*args, params)
  requests =
    if args.size == 1 # どういう呼び出し方をするとこっちを通るのかがわからない...

      reqs = args.first

      reqs.map do |verb, uri, ps = EMPTY_HASH|
        request_params = params
        request_params = request_params.merge(ps) unless ps.empty?
        build_request(verb, uri, request_params)
      end

    else

      # verb = "GET"
      # uris = ["https://example.com"]
      verb, uris = args

      if uris.respond_to?(:each)
        # urisがHashの可能性がある、ってこと?
        uris.enum_for(:each).map do |uri, ps = EMPTY_HASH|
          request_params = params
          request_params = request_params.merge(ps) unless ps.empty?

          # verb           = "GET"
          # uri            = "https://example.com"
          # request_params = {}
          build_request(verb, uri, request_params)
        end
      else
        [build_request(verb, uris, params)]
      end

    end

  raise ArgumentError, "wrong number of URIs (given 0, expect 1..+1)" if requests.empty?

  requests
end

# verb    = "GET"
# uri     = "https://example.com"
# params  = {}
# options = #<HTTPX::Options>
def build_request(verb, uri, params = EMPTY_HASH, options = @options)
  rklass = options.request_class                   # => #<Class> (Class.new(Request)) (lib/httpx/options.rb)
  request = rklass.new(verb, uri, options, params) # => #<HTTPX::Request>
  request.persistent = @persistent                 # => false

  set_request_callbacks(request)

  # (lib/httpx/session.rb)
  #   def set_request_callbacks(request)
  #     request.on(:response, &method(:on_response).curry(2)[request])
  #     request.on(:promise, &method(:on_promise))
  #   end

  request
end
```

### `Session#send_requests`

```ruby
# (lib/httpx/session.rb)

def send_requests(*requests)
  selector = get_current_selector { Selector.new }

  # Selector.newは
  #   #<HTTPX::Selector:0x000000011c0f0650
  #     @timers=#<HTTPX::Timers:0x000000011c0f05b0 @intervals=[]>,
  #     @selectables=[], @is_timer_interval=false>

  # (lib/httpx/session.rb)
  #   def get_current_selector
  #     selector_store[self] || (yield if block_given?)
  #   end
  #
  #   def selector_store
  #     th_current = Thread.current
  #
  #     th_current.thread_variable_get(:httpx_persistent_selector_store) || begin
  #       # Hash#compare_by_identity = selfのキーの一致判定をオブジェクトの同一性で判定するように変更する
  #       {}.compare_by_identity.tap do |store| # store = レシーバの{}
  #         th_current.thread_variable_set(:httpx_persistent_selector_store, store)
  #       end
  #     end
  #   end
  #
  # なので、ここでselectorには#<HTTPX::Selector>格納されている状態になる

  begin
    _send_requests(requests, selector) # => Session#_send_requests

    receive_requests(requests, selector) # => Session#receive_requests
  ensure
    unless @wrapped
      if @persistent
        deactivate(selector)
      else
        close(selector)
      end
    end
  end
end

def _send_requests(requests, selector)
  requests.each do |request|
    # request = #<HTTPX::Request ...>
    send_request(request, selector) # Session#send_request
  end
end

def send_request(request, selector, options = request.options)
  # request.options =
  #   @options=#<HTTPX::Options:0x0000000106b84410
  #              @max_requests=Infinity, @debug_level=1, @ssl={}, @http2_settings={settings_enable_push: 0},
  #              @fallback_protocol="http/1.1", @supported_compression_formats=["gzip", "deflate"],
  #              @decompress_response_body=true, @compress_request_body=true,
  #              @timeout={connect_timeout: 60, settings_timeout: 10, close_handshake_timeout: 10,
  #                        operation_timeout: nil, keep_alive_timeout: 20,
  #                        read_timeout: 60, write_timeout: 60, request_timeout: nil},
  #              @headers_class=#<Class:0x000000010149b0e0>,
  #              @headers={}, @window_size=16384, @buffer_size=16384, @body_threshold_size=114688,
  #              @request_class=#<Class:0x000000010149af00>,
  #              @response_class=#<Class:0x000000010149adc0>,
  #              @request_body_class=#<Class:0x000000010149ac80>,
  #              @response_body_class=#<Class:0x000000010149ab40>,
  #              @pool_class=#<Class:0x000000010149aa00>, @connection_class=#<Class:0x000000010149a8c0>,
  #              @options_class=#<Class:0x000000010149a780>, @persistent=false,
  #              @resolver_class=:native, @resolver_options={cache: true},
  #              @pool_options={}, @ip_families=[2]>,

  error = begin
    catch(:resolve_error) do
      connection = find_connection(request.uri, selector, options) # => Session#find_connection
      connection.send(request) # => Connection#send
    end
  rescue StandardError => e
    e
  end
  return unless error && error.is_a?(Exception)

  raise error unless error.is_a?(Error)

  request.emit(:response, ErrorResponse.new(request, error))

  # request.on(:response)を呼んでいる箇所
  # # (lib/httpx/session.rb) => Session#set_request_callbacks
  #     request.on(:response, &method(:on_response).curry(2)[request])
  #
  # # (lib/httpx/resolver/https.rb) # => Resolver::HTTPS#resolve
  #    request.on(:response, &method(:on_response).curry(2)[request])
end
```

### `Session#set_request_callbacks`

```ruby
def set_request_callbacks(request)
  request.on(:response, &method(:on_response).curry(2)[request])
  request.on(:promise, &method(:on_promise))
end

def on_response(request, response)
  @responses[request] = response # リクエストにレスポンスを対応づける
end
```

### `Resolver::HTTPS#resolve`
- `Resolver::HTTPS#<<`から呼ばれる

```ruby
# (lib/httpx/resolver/https.rb)

# @connections = HTTPSコネクションのプール
def resolve(connection = @connections.first, hostname = nil)
  return unless connection

  # ホスト名と接続のマッピングが存在する場合はそれを再利用する
  hostname ||= @queries.key(connection)

  if hostname.nil?
    hostname = connection.peer.host # ホスト名を取得
    # log
    hostname = @resolver.generate_candidates(hostname).each do |name|
      # 検索候補一つ一つに接続を紐付けて保存
      @queries[name.to_s] = connection
    end.first.to_s # 最初の候補をホスト名として返す
  else
    @queries[hostname] = connection # ホスト名に接続をマッピングし直す
  end

  log { "resolver #{FAMILY_TYPES[@record_type]}: query for #{hostname}" }

  begin
    # DoHサーバへのリクエストを構築
    request = build_request(hostname)

    request.on(:response, &method(:on_response).curry(2)[request])
    request.on(:promise, &method(:on_promise))

    @requests[request] = hostname # このリクエストとホスト名を紐付ける
    resolver_connection.send(request)
    @connections << connection # この名前解決を発行した接続を保存
  rescue ResolveError, Resolv::DNS::EncodeError => e
    reset_hostname(hostname)
    emit_resolve_error(connection, connection.peer.host, e)
  end
end

def on_response(request, response)
  response.raise_for_status # => Response#raise_for_status

  # (lib/httpx/response.rb)
  #   def raise_for_status
  #     return self unless (err = error)
  #     raise err
  #   end
rescue StandardError => e
  hostname = @requests.delete(request)
  connection = reset_hostname(hostname)
  emit_resolve_error(connection, connection.peer.host, e)
else
  # @type var response: HTTPX::Response
  parse(request, response)
ensure
  @requests.delete(request)
end
```

## `Session#find_connection`

```ruby
# (lib/httpx/session.rb)

def find_connection(request_uri, selector, options)
  # selectorに登録済み = リクエスト処理待ちの接続のうち、この宛先に対して接続中のものがあればそれを取得
  if (connection = selector.find_connection(request_uri, options)) # => Selector#find_connection
    return connection
  end

  connection = @pool.checkout_connection(request_uri, options)

  # @pool
  #   #<#<Class:0x000000010358aa08>:0x000000011e9823e8
  #       @max_connections_per_origin=Infinity, @pool_timeout=5, @resolvers={},
  #       @resolver_mtx=#<Thread::Mutex:0x000000011e982230>, @connections=[],
  #       @connection_mtx=#<Thread::Mutex:0x000000011e9821b8>, @origin_counters={}, @origin_conds={}>

  # 取得したconnection (HTTPX::Connection?)
  #   #<#<Class:0x000000010149a8c0>:0x0000000106b80130
  #       @coalesced_connection=nil, @sibling=nil, @current_selector=nil, @current_session=nil,
  #       @main_sibling=false, @cloned=false, @exhausted=false,
  #       @options=#<HTTPX::Options:0x0000000106b84410 ...>,
  #       @type="ssl", @origins=["https://example.com"], @origin=#<URI::HTTPS https://example.com>,
  #       @window_size=16384, @read_buffer=#<HTTPX::Buffer:0x0000000106bafd68 @buffer="", @limit=16384>,
  #       @write_buffer=#<HTTPX::Buffer:0x0000000106bafcc8 @buffer="", @limit=16384>, @pending=[],
  #       @callbacks={error: [#<Proc:0x0000000106bafc28 (lambda)>],
  #                   close: [#<Proc:0x0000000106baf9a8 /path/to/lib/httpx/connection.rb:75>],
  #                   terminate: [#<Proc:0x0000000106baf958 /path/to/lib/httpx/connection.rb:85>],
  #                   altsvc: [#<Proc:0x0000000106baf908 /path/to/lib/httpx/connection.rb:97>]},
  #       @current_timeout=60, @timeout=60, @connected_at=nil, @state=:idle, @inflight=0, @keep_alive_timeout=20>

  # connectionの現在の状態に応じて初期化 (名前解決を含む) 、再利用、再接続などの適当な処理を行う
  case connection.state
  when :idle # 新規接続
    do_init_connection(connection, selector) # 名前解決・接続開始 => Session#do_init_connection

    # 何がしかのクラスに定義されているtransitionメソッドに適切な状態を渡すと@io.connectする、
    # ということになっているらしい
  when :open # 宛先と接続済み
    if options.io # 外部からIOが指定されている場合
      # この接続に対してこのセッションとこのselectorを紐づけ、selectorにこの接続を登録する
      select_connection(connection, selector) # => Session#select_connection
    else
      # この接続に対してこのセッションとこのselectorを紐づける
      pin_connection(connection, selector) # => Session#pin_connection
    end
  when :closed # connectionがclose済み、再利用可能
    # connectionの状態を:idleに戻して再初期化
    connection.idling
    # この接続に対してこのセッションとこのselectorを紐づけ、selectorにこの接続を登録する
    select_connection(connection, selector) # => Session#select_connection
  when :closing # 接続終了中
    # :closeイベントをフックして:closedの場合と同じ処理を行う
    connection.once(:close) do
      connection.idling
      select_connection(connection, selector) # => Session#select_connection
    end
  else
    # この接続に対してこのセッションとこのselectorを紐づける
    pin_connection(connection, selector) # => Session#pin_connection
  end

  connection
end

# (lib/httpx/selector.rb)

def find_connection(request_uri, options)
  # selectorが監視しているオブジェクト群から、この宛先に対して接続済みのものを探して返す
  each_connection.find do |connection|
    connection.match?(request_uri, options)
  end
end

def each_connection(&block)
  return enum_for(__method__) unless block

  # selectorが監視しているオブジェクト群 (Connectionや名前解決のResolverなど)
  @selectables.each do |c|
    if c.is_a?(Resolver::Resolver)
      c.each_connection(&block) # Resolverが持っている複数の接続を列挙してブロックに渡す
    else
      yield c # Connectionをブロックに渡す
    end
  end
end

# (lib/httpx/pool.rb)

def checkout_connection(uri, options)
  # 指定のioがあればそれを利用して接続を作成
  return checkout_new_connection(uri, options) if options.io

  # (lib/httpx/pool.rb)
  #   def checkout_new_connection(uri, options)
  #     options.connection_class.new(uri, options)
  #   end

  @connection_mtx.synchronize do
    acquire_connection(uri, options) || begin

      # (lib/httpx/pool.rb)
      # コネクションプールが保持しているアイドル中の接続のうち、
      # 同じ宛先に対して過去に接続したことのあるものがあればそれを取得する
      #   def acquire_connection(uri, options)
      #     idx = @connections.find_index do |connection|
      #       connection.match?(uri, options)
      #     end
      #
      #     @connections.delete_at(idx) if idx
      #   end

      # 総接続数の上限に到達している?
      if @connections_counter == @max_connections
        # そのうちどれかが接続をcloseするまで最大@pool_timeout秒待機
        @max_connections_cond.wait(@connection_mtx, @pool_timeout)

        # 接続が返却された場合、そのうち利用できるものがあればそれを返す
        if (conn = acquire_connection(uri, options))
          return conn
        end

        # まだ上限に到達している?
        if @connections_counter == @max_connections
          # プール内の接続のうち、close済みのものがあれば取得
          conn = @connections.find { |c| c.state == :closed }

          # なければPoolTimeoutError
          raise PoolTimeoutError.new(
            @pool_timeout,
            "Timed out after #{@pool_timeout} seconds while waiting for a connection"
          ) unless conn

          # close済みの接続をプールから削除
          drop_connection(conn)
        end

      end

      # オリジンに対する接続数の上限に到達している? (同一scheme://host:port)
      if @origin_counters[uri.origin] == @max_connections_per_origin
        # このオリジン向けの接続の空きが出るまで or @pool_timeoutまで待機
        @origin_conds[uri.origin].wait(@connection_mtx, @pool_timeout)

        # 接続の在庫を取得 or PoolTimeoutError
        return acquire_connection(uri, options) ||
          raise(PoolTimeoutError.new(
            @pool_timeout,
            "Timed out after #{@pool_timeout} seconds while waiting for a connection to #{uri.origin}")
          )
      end

      @connections_counter += 1 # 総接続数
      @origin_counters[uri.origin] += 1 # オリジンに対する接続数

      # 総接続数、オリジン別の接続数、いずれも上限以下なので新規接続を作成
      checkout_new_connection(uri, options)
    end
  end
end

# (lib/httpx/session.rb)

def do_init_connection(connection, selector)
  # アドレスファミリが決定していない場合
  resolve_connection(connection, selector) unless connection.family # => Session#resolve_connection
end

def resolve_connection(connection, selector)
  # connection.addresses = 宛先のIPアドレス群を取得済みの場合
  # connection.open? = IOがopenしている場合
  if connection.addresses || connection.open?
    on_resolver_connection(connection, selector) # => Session#on_resolver_connection
    return
  end

  resolver = find_resolver_for(connection, selector) # => Session#find_resolver_for
  # resolver = #<HTTPX::Resolver::Multi ...>

  # すでに取得済みのアドレスを利用する or アドレスファミリごとに名前解決を開始する
  resolver.early_resolve(connection) || resolver.lazy_resolve(connection)
  # => Resolver::Multi#early_resolve / #lazy_resolve
end

def on_resolver_connection(connection, selector)
  from_pool = false # コネクションプールから取得した接続かどうか

  # selectorの中から同じオリジンに対して接続済み、open済みの接続を取得
  # なければプール内からマージ可能な接続を取得
  found_connection = selector.find_mergeable_connection(connection) || begin
    from_pool = true
    @pool.checkout_mergeable_connection(connection)
  end

  # マージ可能かどうか
  # (lib/httpx/connection.rb)
  #   def mergeable?(connection)
  #     return false if @state == :closing || @state == :closed || !@io
  #
  #     return false unless connection.addresses
  #
  #     (
  #       (open? && @origin == connection.origin) ||
  #       !(@io.addresses & (connection.addresses || [])).empty?
  #     ) && @options == connection.options
  #   end

  # 既存の接続が見つからない場合はconnectionをselector に登録して新規接続を開始し、それを返す
  return select_connection(connection, selector) unless found_connection # => Session#select_connection

  # 既存の接続がまだopenしている場合
  if found_connection.open?
    # 即座に統合
    coalesce_connections(found_connection, connection, selector, from_pool)
  else
    # openイベントを待って統合
    found_connection.once(:open) do
      coalesce_connections(found_connection, connection, selector, from_pool)
    end
  end

  # (lib/httpx/session.rb)
  # 接続の統合を行う
  #   conn1 = 同じオリジンに対して接続済み、open済みの既存の接続
  #   conn2 = 新たに作成しようとしている接続
  #   selector = 現在のselector
  #   from_pool = conn1をコネクションプールから取得したかどうか
  #
  #   def coalesce_connections(conn1, conn2, selector, from_pool)
  #     # Connection#coalescable?
  #     #   - いずれもHTTP/2接続
  #     #   - 証明書のSANにconn2のホスト名が含まれる
  #     #   - SNIやALPN が一致している
  #     #   - プロトコルがTLS であり、サーバ認証済み など
  #     unless conn1.coalescable?(conn2) # 統合できない場合
  #       # conn2は独立した接続としてselectorに登録
  #       select_connection(conn2, selector) # => Session#select_connection
  #       # conn1をプールから取得した場合は再びプールに戻す
  #       @pool.checkin_connection(conn1) if from_pool
  #       return false
  #     end
  #
  #     # conn2をconn1に統合。以降conn2に対するリクエストはconn1に経由で処理される
  #     conn2.coalesced_connection = conn1
  #     select_connection(conn1, selector) if from_pool # => Session#select_connection
  #     deselect_connection(conn2, selector)
  #     true
  #   end
end

def find_resolver_for(connection, selector)
  resolver = selector.find_resolver(connection.options)

  # (lib/httpx/selector.rb)
  #   def find_resolver(options)
  #     # @selectables = selector が現在監視している全オブジェクト
  #     res = @selectables.find do |c|
  #       # 同じ設定のResolverがあれば返す
  #       c.is_a?(Resolver::Resolver) && options == c.options
  #     end
  #
  #     res.multi if res
  #   end

  unless resolver
    # 使用中ではないResolverを取得または新規作成
    resolver = @pool.checkout_resolver(connection.options)

    # (lib/httpx/pool.rb)
    #   def checkout_resolver(options)
    #     resolver_type = options.resolver_class # 使用するDNSリゾルバの種類を特定
    #     resolver_type = Resolver.resolver_for(resolver_type, options) # 実際のResolverオブジェクトを作成
    #
    #     # (lib/httpx/resolver.rb)
    #     #   def resolver_for(resolver_type)
    #     #     case resolver_type
    #     #     when :native then Native
    #     #     when :system then System
    #     #     when :https then HTTPS
    #     #     else
    #     #       return resolver_type if resolver_type.is_a?(Class) && resolver_type < Resolver
    #     #
    #     #       raise Error, "unsupported resolver type (#{resolver_type})"
    #     #     end
    #     #   end
    #
    #     @resolver_mtx.synchronize do
    #       resolvers = @resolvers[resolver_type] # @resolvers = リゾルバの種類ごとにResolverの在庫を持つHash
    #
    #       idx = resolvers.find_index do |res| # 既存のResolverから、同じオプションのものを取得
    #         res.options == options
    #       end
    #       resolvers.delete_at(idx) if idx
    #     end || checkout_new_resolver(resolver_type, options) # なければ新しいResolverを作成
    #
    #     # (lib/httpx/pool.rb)
    #     #   def checkout_new_resolver(resolver_type, options)
    #     #     if resolver_type.multi?
    #     #       Resolver::Multi.new(resolver_type, options)
    #     #     else
    #     #       resolver_type.new(options)
    #     #     end
    #     #   end
    #   end

    resolver.current_session = self
    resolver.current_selector = selector
  end

  resolver
end

# (lib/httpx/resolver/multi.rb)

def early_resolve(connection)
  # 接続先ホスト名
  hostname = connection.peer.host

  # キャッシュがある場合: すでにこのconnectionに関連付けられたAddrinfo(s)、もしくはIP文字列があればそれを取得
  # なければfalseを返す
  addresses = @resolver_options[:cache] && (connection.addresses || HTTPX::Resolver.nolookup_resolve(hostname))
  return false unless addresses

  resolved = false

  # Addrinfo(s)をアドレスファミリごとにグルーピングし、IPv6を優先するように並び替え
  addresses.group_by(&:family).sort { |(f1, _), (f2, _)| f2 <=> f1 }.each do |family, addrs|
    # アドレスファミリに対応するリゾルバを選択
    resolver = @resolvers.find { |r| r.family == family } || @resolvers.first

    next unless resolver # this should ever happen

    # リゾルバに対し、このconnectionの名前解決が完了したことを通知
    resolver.emit_addresses(connection, family, addrs, true)

    resolved = true
  end

  resolved
end

# (lib/httpx/resolver/resolver.rb)

def emit_addresses(connection, family, addresses, early_resolve = false)
  # addressesをIPAddrに変換
  addresses.map! do |address|
    address.is_a?(IPAddr) ? address : IPAddr.new(address.to_s)
  end

  # connectionに対してこのaddressesと同じ内容のアドレスリストが設定されている場合はreturn
  return if !early_resolve && connection.addresses && !addresses.intersect?(connection.addresses)

  log do
    "resolver #{FAMILY_TYPES[RECORD_TYPES[family]]}: " \
      "answer #{connection.peer.host}: #{addresses.inspect} (early resolve: #{early_resolve})"
  end

  # HEのための遅延? (アドレスリストをかたまりで渡している気がする...)
  if !early_resolve && # early_resolveからの呼び出しの場合はtrue
     @current_selector && selectorが存在する
     family == Socket::AF_INET && # IPv4
     !connection.io && # 接続済みではない
     connection.options.ip_families.size > 1 && # IPv4 / IPv6両方をサポートしている
     addresses.first.to_s != connection.peer.host.to_s # 接続先ホストがIPアドレスではない

    log { "resolver #{FAMILY_TYPES[RECORD_TYPES[family]]}: applying resolution delay..." }

    # 50ms後に名前解決を通知
    @current_selector.after(0.05) do
      unless connection.addresses && addresses.intersect?(connection.addresses)
        emit_resolved_connection(connection, addresses, early_resolve)
        # => Resolver::Resolver#emit_resolved_connection
      end
    end
  else
    # 名前可決を通知 => Resolver::Resolver#emit_resolved_connection
    emit_resolved_connection(connection, addresses, early_resolve)
  end
end

# (lib/httpx/resolver/resolver.rb)↲

def emit_resolved_connection(connection, addresses, early_resolve)
  begin
    # connectionに解決済みアドレスリストを設定
    # 以降、connectionはaddressesに対して接続できるようになる
    connection.addresses = addresses

    return if connection.state == :closed

    # リゾルバが保持するコールバックリスト (callbacks[:resolve])に対してイベントを発火 (引数connection)
    emit(:resolve, connection)
  rescue StandardError => e # SocketErrorやIOErrorが発生した場合
    if early_resolve
      # connectionの状態をリセットして例外を呼び出し元に伝搬する
      connection.force_reset
      throw(:resolve_error, e)
    else
      # リゾルバが保持するコールバックリスト (callbacks[:error])に対してイベントを発火 (引数connection, e)
      emit(:error, connection, e)
    end
  end
end

# (lib/httpx/resolver/multi.rb)

def lazy_resolve(connection)
  # @resolvers = [#<HTTPX::Resolver::Native ...>, ...]
  @resolvers.each do |resolver|
    # resolverに対してこの接続を名前解決する対象として登録する
    resolver << @current_session.try_clone_connection(connection, @current_selector, resolver.family)
    # => Resolver::Native#<<
    # => Session#try_clone_connection
    next if resolver.empty?

    @current_session.select_resolver(resolver, @current_selector) # => Session#select_connection
  end
end

# (lib/httpx/session.rb)

def try_clone_connection(connection, selector, family)
  connection.family ||= family

  # アドレスファミリが同じ場合はそのconnectionを返す
  return connection if connection.family == family

  # アドレスファミリが異なる場合、connectionを複製してアドレスファミリを設定
  new_connection = connection.class.new(connection.origin, connection.options)
  new_connection.family = family

  # 元のconnectionと新しいnew_connectionを関連づける (同じ宛先に対するIPv6/IPv4接続を関連づける)
  connection.sibling = new_connection

  # 複製したnew_connectionをresolverに登録して名前解決を開始
  do_init_connection(new_connection, selector) # => Session#do_init_connection
  new_connection
end

# (lib/httpx/resolver/native.rb)

def <<(connection)
  if @nameserver.nil? # DNSサーバが存在しない場合はResolveError
    ex = ResolveError.new("No available nameserver")
    ex.set_backtrace(caller)
    connection.force_reset
    throw(:resolve_error, ex)
  else
    # @connectionsにconnectionを追加してresolv
    @connections << connection
    resolve # => Resolver::Native#resolve
  end
end

def resolve(connection = nil, hostname = nil)
  # @connectionsを先頭からたどり、closeした接続が残っている場合は取り除く
  @connections.shift until @connections.empty? || @connections.first.state != :closed

  # まだクエリが発行されていないconnectionを取得、なければエラー
  connection ||= @connections.find { |c| !@queries.value?(c) }
  raise Error, "no URI to resolve" unless connection

  # 書き込みバッファが空でない場合は何もしない
  return unless @write_buffer.empty?

  # 引数に指定がなければ@queriesに登録されているホスト名を取得
  hostname ||= @queries.key(connection)

  if hostname.nil? # hostnameが未指定の場合
    # connectionのpeer.hostから取得
    hostname = connection.peer.host

    log do
      "resolver #{FAMILY_TYPES[@record_type]}: " \
        "resolve IDN #{connection.peer.non_ascii_hostname} as #{hostname}"
    end if connection.peer.non_ascii_hostname

    # hostnameに候補を格納
    hostname = generate_candidates(hostname).each do |name|
      # (lib/httpx/resolver/native.rb)
      #   def generate_candidates(name)
      #     return [name] if name.end_with?(".")
      #
      #     candidates = []
      #     name_parts = name.scan(/[^.]+/)
      #     candidates = [name] if @ndots <= name_parts.size - 1
      #     candidates.concat(@search.map { |domain| [*name_parts, *domain].join(".") })
      #     fname = "#{name}."
      #     candidates << fname unless candidates.include?(fname)
      #
      #     candidates
      #   end

      # @queriesにconnectionを登録
      @queries[name] = connection
    end.first # generate_candidatesが返す最初の候補をクエリ対象とする
  else
    # @queriesにconnectionを登録
    @queries[hostname] = connection
  end

  @name = hostname
  log { "resolver #{FAMILY_TYPES[@record_type]}: query for #{hostname}" }

  begin
    # encode_dns_queryでDNSクエリをエンコードして、@write_bufferに書き込む
    # (この後selectorがソケットに書き込みイベントを発火させることで送信される) (Resolver::Native#dwrite)
    # @write_buffer = #<HTTPX::Buffer:0x000000012036e9c8 @buffer="", @limit=512>
    @write_buffer << encode_dns_query(hostname)

    # (lib/httpx/resolver.rb)
    #  def encode_dns_query(hostname, type: Resolv::DNS::Resource::IN::A, message_id: generate_id)
    #    Resolv::DNS::Message.new(message_id).tap do |query|
    #      query.rd = 1
    #      query.add_question(hostname, type)
    #    end.encode
    #  end

  rescue Resolv::DNS::EncodeError => e
    reset_hostname(hostname, connection: connection)
    @connections.delete(connection)
    emit_resolve_error(connection, hostname, e)
    close_or_resolve
  end
end
```

### `Session#select_connection`

```
# (lib/httpx/session.rb)

alias_method :select_resolver, :select_connection

def select_connection(connection, selector)
  # この接続に対して、このセッションとこのselectorを紐づける
  pin_connection(connection, selector) # => Session#pin_connection

  # このselectorにこの接続を登録する
  selector.register(connection)
end

# (lib/httpx/session.rb)
def pin_connection(connection, selector)
  connection.current_session = self
  connection.current_selector = selector
end
```

## `Connection#send`

```ruby
# (lib/httpx/connection.rb)

def send(request)
  # この接続が他の接続に合流している場合、合流先の接続を利用して送信を行う
  return @coalesced_connection.send(request) if @coalesced_connection

  # @parserが存在している = HTTPX::Connection::HTTP2 (HTTP/1の場合はHTTPX::Connection::HTTP1)
  # !@write_buffer.full?  = 送信バッファに空きがある
  if @parser && !@write_buffer.full?

    # @response_received_at = 最後にレスポンスを受け取った時刻
    # @keep_alive_timeout   = Keep-Alive時間
    # @response_received_atが@keep_alive_timeoutを超えている場合、接続がタイムアウトしていないか確認のためpingを送信
    if @response_received_at && @keep_alive_timeout &&
       Utils.elapsed_time(@response_received_at) > @keep_alive_timeout
      log(level: 3) { "keep alive timeout expired, pinging connection..." }

      @pending << request # 現在のリクエストを@pendingキューに追加
      transition(:active) if @state == :inactive # 状態を:activeに変更
      parser.ping # pingを送信 # => Connection#parser
      return
    end

    send_request_to_parser(request) # => Connection#send_request_to_parser

  else
    # 現在のリクエストを@pendingキューに追加
    @pending << request
  end
end

def parser
  @parser ||= build_parser # => Connection#build_parser
end

def build_parser(protocol = @io.protocol)
  parser = self.class.parser_type(protocol).new(@write_buffer, @options)

  # (lib/httpx/connection.rb)
  #   def parser_type(protocol)
  #     case protocol
  #     when "h2" then HTTP2
  #     when "http/1.1" then HTTP1
  #     else
  #       raise Error, "unsupported protocol (##{protocol})"
  #     end
  #   end

  set_parser_callbacks(parser) # => Connection#set_parser_callbacks
  parser
end

def send_request_to_parser(request)
  @inflight += 1 # 送信済みかつレスポンス未受信のリクエスト数をカウント
  request.peer_address = @io.ip # 送信先IPアドレスをリクエストに指定
  parser.send(request) # 送信 => Connection::HTTP1#send / Connection::HTTP2#send

  set_request_timeouts(request)

  # (lib/httpx/connection.rb)
  #   def set_request_timeouts(request)
  #     set_request_write_timeout(request)
  #     set_request_read_timeout(request)
  #     set_request_request_timeout(request)
  #   end

  return unless @state == :inactive

  transition(:active) # 状態を:activeに変更
end
```

### `Connection#set_parser_callbacks`

```ruby
# (lib/httpx/connection.rb)

def set_parser_callbacks(parser)
  # レスポンスを受信したとき
  parser.on(:response) do |request, response|
    # レスポンスヘッダをパースし、Alt-Svcが含まれている場合
    AltSvc.emit(request, response) do |alt_origin, origin, alt_params|
      emit(:altsvc, alt_origin, origin, alt_params) # :altsvcイベントを発火
    end

    @response_received_at = Utils.now # この接続で最後にレスポンスを受信した時刻
    @inflight -= 1 # 送信済みかつレスポンス待ちのリクエストのカウントを減算
    request.emit(:response, response) # HTTPX::Requestオブジェクトに対して:responseイベントを発火
  end

  # ALTSVCフレームを受信した場合
  parser.on(:altsvc) do |alt_origin, origin, alt_params|
    emit(:altsvc, alt_origin, origin, alt_params) # :altsvcイベントを発火
  end

  # PINGフレームを受信した時
  parser.on(:pong, &method(:send_pending)) # @pendingに積まれたリクエストを送信する

  # (lib/httpx/connection.rb)
  #   def send_pending
  #     while !@write_buffer.full? && (request = @pending.shift)
  #       send_request_to_parser(request)
  #     end
  #   end

  # PUSH_PROMISEフレームを受信した時
  parser.on(:promise) do |request, stream|
    request.emit(:promise, parser, stream) # :promiseイベントを発火
  end

  # GOAWAYフレームを受信した時 (HTTP/2)
  # 送信可能なリクエスト数の上限 (Keep-Aliveの上限値など) に達した時 (HTTP/1)
  parser.on(:exhausted) do
    # この接続ではこれ以上送信できない

    @exhausted = true
    current_session = @current_session
    current_selector = @current_selector

    begin
      parser.close
      @pending.concat(parser.pending) # 未送信・送信途中のリクエストがあれば@pendingに追加
    ensure
      # parser.closeなどの副作用で@current_session / @current_selectorなどの値が変わるかもしれない
      @current_session = current_session
      @current_selector = current_selector
    end

    case @state # この接続の状態
    when :closed
      idling
      @exhausted = false
    when :closing
      once(:closed) do # closeしたら
        idling
        @exhausted = false
      end
    end

    # (lib/httpx/connection.rb)
    #  def idling
    #    purge_after_closed # ソケットを閉じる、読み取り用のバッファを空にする、タイムアウト設定ををリセット
    #    @write_buffer.clear # 未送信リクエストを空にする
    #    transition(:idle) # 状態を:idle = 再利用可能な状態に変更
    #    @parser = nil if @parser
    #  end
    #
    #  def purge_after_closed
    #    @io.close if @io
    #    @read_buffer.clear
    #    @timeout = nil
    #  end
  end

  # ORIGINフレームを受信した時
  # (この接続でどのオリジン = ホスト名を扱えるか。接続の合流に使用する)
  parser.on(:origin) do |origin|
    # @originsにホスト名を追加する
    @origins |= [origin]
  end

  # 接続がcloseしたとき
  parser.on(:close) do |force|
    if force # 強制終了
      reset

      # (lib/httpx/connection.rb)
      #   def reset
      #     return if @state == :closing || @state == :closed
      #     transition(:closing)
      #     transition(:closed)
      #   end

      emit(:terminate) # :terminateイベントを発火
    end
  end

  # クローズハンドシェイクが完了した時 (GOAWAYフレーム受信後にすべてのストリームがcloseした場合など)
  parser.on(:close_handshake) do
    consume
  end

  # 接続、またはストリームがプロトコルレベルでリセットによって中断された時 (RST_STREAM, TCP RSTなど)
  parser.on(:reset) do
    # 未完了のリクエストを@pendingに戻す
    @pending.concat(parser.pending) unless parser.empty?

    # 一時退避 (resetを呼ぶと@current_sessionがクリアされるため)
    current_session = @current_session
    current_selector = @current_selector

    reset

    # 未送信のリクエストがあれば再送準備
    unless @pending.empty?
      idling
      @current_session = current_session
      @current_selector = current_selector
    end
  end

  # このリクエストに対してタイムアウトの監視が始まる時
  parser.on(:current_timeout) do
    # @current_timeout = 現在処理中のリクエストのタイムアウト
    # @timeout = この接続全体のタイムアウト
    # parser.timeout = このリクエスト単位の残り時間
    @current_timeout = @timeout = parser.timeout
  end

  # この接続に対してKeep-Alive (HTTP/1)、Ping、Goaway、Idle (HTTP/2) のタイマーが設定された時
  parser.on(:timeout) do |tout|
    @timeout = tout
  end

  # HTTPパーサからエラー通知を受けた時
  parser.on(:error) do |request, error|
    case error
    when :http_1_1_required # サーバがALPN negotiationを拒否し、HTTP/1.1 requiredを返した場合

      current_session = @current_session
      current_selector = @current_selector
      parser.close # このパーサではもはや通信できない

      # 同じSessionとSelectorから別の接続を取得
      other_connection = current_session.find_connection(
        @origin,
        current_selector,
        @options.merge(ssl: { alpn_protocols: %w[http/1.1] }) # ALPNの候補を"http/1.1"に限定
      )

      # この接続が保持している情報を新しい接続に引き継ぐ
      # @pending, @origins, @sibling, @coalesced_connectionなど
      other_connection.merge(self)

      request.transition(:idle) # リクエストの状態をidle に戻す
      other_connection.send(request) # 新しい接続を利用して再送
      next # parser.on(:error)ブロックから抜ける

    when OperationTimeoutError # read / write / connectがOperationTimeoutErrorに達した場合
      next unless request.active_timeouts.empty? # リクエストの個別のtimeout時間内の場合は何もしない
    end

    # 上記の2ケース以外はエラーをリクエストに紐づけてレスポンスとして返す
    response = ErrorResponse.new(request, error)
    request.response = response
    request.emit(:response, response)
  end
end
```

### `HTTPX::Connection::HTTP1#send`

```ruby
# (lib/httpx/connection/http1.rb)
# parser.sendとして呼ばれている

def send(request)
  # Keep-Aliveヘッダなどでサーバから指定されたリクエスト数の上限値を超えている場合
  unless @max_requests.positive?
    @pending << request # このリクエストを@pendingに積む (新しい接続を利用して送信される)
    return
  end

  # 同じリクエストがすでに送信キューに入っている場合は重複して追加しないようにする
  return if @requests.include?(request)

  @requests << request # 送信キューにこのリクエストを追加
  @pipelining = true if @requests.size > 1 # リクエストが2件以上溜まったらパイプライニングを有効化

  # selectorがこの接続の@ioをwritableと判断すると実際の書き込みが行われる
end
```

### `HTTPX::Connection::HTTP2#send`

```ruby
# (lib/httpx/connection/http2.rb)
# parser.sendとして呼ばれている

def send(request, head = false)
  # 同時オープン可能なストリーム数を確認し、新しいストリームを開けるかを判定
  unless can_buffer_more_requests?
    # このリクエストを@pendingに積む (新しい接続を利用して送信される)
    if head # 優先再送
      @pending.unshift(request)
    else
      @pending << request
    end

    return false
  end

  # すでにこのリクエストに対応するストリームが存在すれば再利用する (stream)
  unless (stream = @streams[request])
    # なければ新しいストリーム (HTTP2::Client::Stream) を作成
    stream = @connection.new_stream
    handle_stream(stream, request)

    # (lib/httpx/connection/http2.rb)
    #   def handle_stream(stream, request)
    #     request.on(:refuse, &method(:on_stream_refuse).curry(3)[stream, request])
    #     stream.on(:close, &method(:on_stream_close).curry(3)[stream, request])
    #
    #     stream.on(:half_close) do
    #       log(level: 2) { "#{stream.id}: waiting for response..." }
    #     end
    #
    #     stream.on(:altsvc, &method(:on_altsvc).curry(2)[request.origin])
    #     stream.on(:headers, &method(:on_stream_headers).curry(3)[stream, request])
    #     stream.on(:data, &method(:on_stream_data).curry(3)[stream, request])
    #   end

    @streams[request] = stream # リクエストとストリームを1:1で紐づけ
    @max_requests -= 1 # 利用可能なストリーム枠を減らす
  end

  handle(request, stream) # フレームを生成、送信 => Connection::HTTP2#handle
  true
rescue ::HTTP2::Error::StreamLimitExceeded # サーバからRST_STREAMが返ってきた場合など (ストリームの上限)
  @pending.unshift(request) # リクエストを再試行できるように@pendingの先頭に戻す
  false
end

def handle(request, stream)
  catch(:buffer_full) do # 送信バッファがいっぱいになったら一時停止
    # リクエストのステートを:idle -> :headersに移行
    request.transition(:headers)
    # HEADERSフレームを構築してストリームへ書き込み
    join_headers(stream, request) if request.state == :headers # => Connection::HTTP2#join_headers

    # リクエストのステートを:headers -> :bodyに移行
    request.transition(:body)
    # DATAフレームを構築してストリームへ書き込み
    join_body(stream, request) if request.state == :body # => Connection::HTTP2#join_body

    # リクエストのステートを:body -> :trailersに移行
    request.transition(:trailers)
    # TRAILERSフレームを構築してストリームへ書き込み
    join_trailers(stream, request) if request.state == :trailers && !request.body.empty?
    # => Connection::HTTP2#join_trailers

    # リクエストのステートを:trailers -> :doneに移行
    request.transition(:done)
  end
end

def join_headers(stream, request)
  # 擬似ヘッダを作成
  extra_headers = set_protocol_headers(request)

  # HTTP/2のforbidden headerである"host"ヘッダが含まれている場合は警告を出し、authorityヘッダに書き換える
  if request.headers.key?("host")
    log { "forbidden \"host\" header found (#{request.headers["host"]}), will use it as authority..." }
    extra_headers[":authority"] = request.headers["host"]
  end

  log(level: 1, color: :yellow) do
    request.headers.merge(extra_headers).each.map { |k, v| "#{stream.id}: -> HEADER: #{k}: #{v}" }.join("\n")
  end

  # ストリームにヘッダをHEADERSフレームとして書き込む
  stream.headers(request.headers.each(extra_headers), end_stream: request.body.empty?)
end

def join_body(stream, request)
  return if request.body.empty?

  # @drains (途中で送信を中断したリクエストの残り) もしくは直接リクエストからボディのチャンクを取得
  chunk = @drains.delete(request) || request.drain_body

  while chunk # チャンクごとに送信
    next_chunk = request.drain_body

    log(level: 1, color: :green) { "#{stream.id}: -> DATA: #{chunk.bytesize} bytes..." }
    log(level: 2, color: :green) { "#{stream.id}: -> #{chunk.inspect}" }

    # ストリームにチャンクをDATAフレームとして書き込む
    stream.data(chunk, end_stream: !(next_chunk || request.trailers? || request.callbacks_for?(:trailers)))

    # 次のチャンクがあり、かつ送信バッファがいっぱいの場合
    if next_chunk && (@buffer.full? || request.body.unbounded_body?)
      @drains[request] = next_chunk # 次のチャンクを@drainsに保存
      throw(:buffer_full)
    end

    chunk = next_chunk
  end

  return unless (error = request.drain_error)
  on_stream_refuse(stream, request, error) # ストリーム拒否
end

def join_trailers(stream, request)
  unless request.trailers?
    # トレーラがなく、かつトレーラ送信時に呼び出されるコールバックが設定されている場合は空のDATAフレームを送信
    stream.data("", end_stream: true) if request.callbacks_for?(:trailers)
    return
  end

  log(level: 1, color: :yellow) do
    request.trailers.each.map { |k, v| "#{stream.id}: -> HEADER: #{k}: #{v}" }.join("\n")
  end

  # ストリームにトレーラヘッダをHEADERSフレームとして書き込む
  stream.headers(request.trailers.each, end_stream: true)
end
```

## `Session#receive_requests`

```ruby
# (lib/httpx/session.rb)

# 元のリクエストの送信順にresponsesを整列して返す
def receive_requests(requests, selector)
  # @type var responses: Array[response]
  responses = []

  loop do
    request = requests.first # 先頭のリクエストを取得
    return responses unless request # リクエストが空になったらレスポンスを返す

    catch(:coalesced) {
      selector.next_tick # => Selector#next_tick
    } until (
      response = fetch_response(request, selector, request.options)

      # (lib/httpx/session.rb)
      #   def fetch_response(request, _selector, _options)
      #     @responses.delete(request)
      #   end
    )

    request.emit(:complete, response) # リクエストに対して:completeイベントを通知
    responses << response
    requests.shift

    break if requests.empty?

    # selectorに監視中のI/Oが残っている場合、まだ受信中の可能性があるため、もう一周ループをくり返す
    next unless selector.empty?

    # ハンドシェイクエラーが発生するなどしてエラーレスポンスが送信済みになっている、
    # かつ未処理になっているリクエストがある可能性があるため、
    # ここでリクエストを処理することでエラーを回収する
    while (request = requests.shift)
      response = fetch_response(request, selector, request.options)
      request.emit(:complete, response) if response
      responses << response
    end
    break
  end

  responses
end
```

### `Selector#next_tick`

```ruby
# (lib/httpx/selector.rb)

def next_tick
  catch(:jump_tick) do
    timeout = next_timeout # 次のタイムアウトまでの残り時間を取得

    if timeout && timeout.negative? # タイムアウト済みの場合
      @timers.fire # 期限切れのタイマーを発火
      throw(:jump_tick) # 残りの処理をスキップ
    end

    begin
      select(timeout, &:call) # => Selector#select
      @timers.fire
    rescue TimeoutError => e
      @timers.fire(e) # 強制的にタイマーを発火
    end
  end
rescue StandardError => e
  emit_error(e) # すべてのIOに:errorイベントを通知
rescue Exception # rubocop:disable Lint/RescueException
  each_connection do |conn|
    conn.force_reset
    conn.disconnect
  end

  raise
end

def select(interval, &block)
  return if interval.nil? && @selectables.empty? # 監視対象が空の場合は何もしない

  return select_one(interval, &block) if @selectables.size == 1 # 監視対象のIOがひとつ => Selector#select_one

  select_many(interval, &block) # 監視対象のIOが複数 => Selector#select_many
end

def select_one(interval)
  io = @selectables.first
  return unless io

  # どんなイベントを待つかによってwait_readable / wait_writable / waitを呼び出す
  interests = io.interests
  result = case interests
           when :r then io.to_io.wait_readable(interval)
           when :w then io.to_io.wait_writable(interval)
           when :rw then io.to_io.wait(interval, :read_write)
           when nil then return
  end

  unless result || interval.nil?
    # タイムアウト発生時の処理
    io.handle_socket_timeout(interval) unless @is_timer_interval
    return
  end

  # next_tickの中でselect(timeout, &:call)のように呼び出している。のでこの場合はio.call
  yield io
end

def select_many(interval, &block)
  r, w = nil

  # 監視対象のIOをr, wに振り分ける
  @selectables.delete_if do |io|
    interests = io.interests

    (r ||= []) << io if READABLE.include?(interests)
    (w ||= []) << io if WRITABLE.include?(interests)

    io.state == :closed
  end

  # IOの準備ができるまで待機
  readers, writers = IO.select(r, w, nil, interval)

  # タイムアウト発生時の処理
  if readers.nil? && writers.nil? && interval
    [*r, *w].each { |io| io.handle_socket_timeout(interval) }
    return
  end

  # 読み書き可能なIOに対して.callを読んでいく
  if writers
    readers.each do |io|
      yield io

      # so that we don't yield 2 times
      writers.delete(io)
    end if readers

    writers.each(&block)
  else
    readers.each(&block) if readers
  end
end
```

## `HTTPX::Callbacks`

```ruby
# (lib/httpx/callbacks.rb)

module HTTPX
  module Callbacks
    # typeに対してactionを登録する
    def on(type, &action)
      callbacks(type) << action
      action
    end

    # typeに対して一回だけ発火するactionを登録する
    def once(type, &block)
      on(type) do |*args, &callback|
        block.call(*args, &callback)
        :delete
      end
    end

    # typeに対してactionを発火する
    def emit(type, *args)
      log { "emit #{type.inspect} callbacks" } if respond_to?(:log)
      callbacks(type).delete_if { |pr| :delete == pr.call(*args) } # rubocop:disable Style/YodaCondition
    end

    # typeが登録されているかどうか
    def callbacks_for?(type)
      @callbacks.key?(type) && @callbacks[type].any?
    end

    protected

    def callbacks(type = nil)
      return @callbacks unless type

      @callbacks ||= Hash.new { |h, k| h[k] = [] }
      @callbacks[type]
    end
  end
end
```

- 全体の流れ
- プロトコルの切り替えをどこで行なっているのか
- プロキシへの対応はどのように行なっているのか
