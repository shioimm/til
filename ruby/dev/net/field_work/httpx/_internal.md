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

## `Session`

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

      requests = args.first.is_a?(Request) ? args : build_requests(*args, params)

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

      # WIP
      responses = send_requests(*requests)
      return responses.first if responses.size == 1

      responses
    end

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
  end
end
```

## `Callbacks#on`

```ruby
# (lib/httpx/callbacks.rb)
# HTTPX::Requestからincludeされている

module HTTPX
  module Callbacks
    def on(type, &action)
      callbacks(type) << action
      action
    end

    def callbacks(type = nil)
      return @callbacks unless type

      @callbacks ||= Hash.new { |h, k| h[k] = [] }
      @callbacks[type]
    end
  end
end
```

## `Session#send_requests`

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
    # WIP
    _send_requests(requests, selector)

    # (lib/httpx/session.rb)
    #   def _send_requests(requests, selector)
    #     requests.each do |request|
    #       send_request(request, selector)
    #     end
    #   end

    receive_requests(requests, selector)
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

# request.options
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

def send_request(request, selector, options = request.options)
  error = begin
    catch(:resolve_error) do
      # WIP
      connection = find_connection(request.uri, selector, options)
      connection.send(request)
    end
  rescue StandardError => e
    e
  end
  return unless error && error.is_a?(Exception)

  raise error unless error.is_a?(Error)

  request.emit(:response, ErrorResponse.new(request, error))
end

def find_connection(request_uri, selector, options)
  # WIP
  # selectorに登録済み = リクエスト処理待ちの接続のうち、この宛先に対して接続中のものがあればそれを取得
  if (connection = selector.find_connection(request_uri, options))
    return connection
  end

  connection = @pool.checkout_connection(request_uri, options)

  # @pool
  #   #<#<Class:0x000000010358aa08>:0x000000011e9823e8
  #       @max_connections_per_origin=Infinity, @pool_timeout=5, @resolvers={},
  #       @resolver_mtx=#<Thread::Mutex:0x000000011e982230>, @connections=[],
  #       @connection_mtx=#<Thread::Mutex:0x000000011e9821b8>, @origin_counters={}, @origin_conds={}>

  # 取得したconnection
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

  case connection.state
  when :idle
    do_init_connection(connection, selector)
  when :open
    if options.io
      select_connection(connection, selector)
    else
      pin_connection(connection, selector)
    end
  when :closed
    connection.idling
    select_connection(connection, selector)
  when :closing
    connection.once(:close) do
      connection.idling
      select_connection(connection, selector)
    end
  else
    pin_connection(connection, selector)
  end

  connection
end
```

## `Selector#find_connection`

```ruby
# (lib/httpx/selector.rb)

# WIP
def find_connection(request_uri, options)
  each_connection.find do |connection|
    connection.match?(request_uri, options)
  end
end

def each_connection(&block)
  return enum_for(__method__) unless block

  @selectables.each do |c|
    if c.is_a?(Resolver::Resolver)
      c.each_connection(&block)
    else
      yield c
    end
  end
end
```

## `Pool#checkout_connection`

```ruby
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
        # そのうちどれかが接続をクローズするまで最大@pool_timeout秒待機
        @max_connections_cond.wait(@connection_mtx, @pool_timeout)

        # 接続が返却された場合、そのうち利用できるものがあればそれを返す
        if (conn = acquire_connection(uri, options))
          return conn
        end

        # まだ上限に到達している?
        if @connections_counter == @max_connections
          # プール内の接続のうち、クローズ済みのものがあれば取得
          conn = @connections.find { |c| c.state == :closed }

          # なければPoolTimeoutError
          raise PoolTimeoutError.new(
            @pool_timeout,
            "Timed out after #{@pool_timeout} seconds while waiting for a connection"
          ) unless conn

          # クローズ済みの接続をプールから削除
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
```
