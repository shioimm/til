## client.rb
https://github.com/nurse/net-http/blob/8ac46b06f4c63388d03c59a1f05c036a9e8a99b3/lib/net/http/client.rb

```ruby
# 元URLを持つClientオブジェクトを作成
client = Net::HTTP.client('https://files.example.com') # => Net::HTTP.client

File.open('download.bin', 'wb') do |file|
  # #stream = #build_request -> #perform
  client.stream(:get, '/large-file') do |response| # => Client#stream
    # HTTPリクエストを送り、レスポンスボディを少しずつ読み取る
    response.raise_for_status

    # サーバから受信したメッセージボディをチャンクごとにdownload.binへ書き込み
    response.each_body_chunk { |chunk| file.write(chunk) }
  end
end

# Requestオブジェクトを作成
request = client.build_request(:post, '/items', json: {name: 'one'}) # => Client#build_request
# Requestオブジェクトの内容を上書き
request = request.with(headers: {'X-Trace' => 'example'}) # => Request#with

# リクエストを送信
response = client.perform(request) # => Client#perform

# ブロックなしで呼び出す -> レスポンス全文を読み込み
# ブロックありで呼び出す -> レスポンスをチャンクごとに読み込み

client.close
Net::HTTP::Client.shutdown # Explicitly release the process-wide connections.
```

---

```ruby
module Net
  class HTTP < Protocol
    def self.client(base_url = nil, **options)
      client = Client.new(base_url, **options) # => Client#initialize
      return client unless block_given?

      begin
        yield client
      ensure
        client.close
      end
    end
  end
end
```

```ruby
# lib/net/http/client.rb

# frozen_string_literal: true
require 'net/http'

module Net
  class HTTP
    class Client; end
  end
end

require_relative 'client/runtime'
require_relative 'client/request'
require_relative 'client/cookie_jar'
require_relative 'client/response'
require_relative 'client/pool'
require_relative 'client/connection_factory'
require 'digest'

module Net
  class HTTP
    # A reusable synchronous HTTP client. Compatible connections are automatically
    # shared process-wide; cookies, authentication and cancellation are client-local.
    class Client
      # Client::DEFAULTS
      DEFAULTS = {
        headers: {},
        protocols: [:http2, :http1],
        proxy: :ENV,
        tls: {},
        open_timeout: 60,
        read_timeout: 60,
        write_timeout: 60,
        pool_timeout: 60,
        timeout: nil,
        idle_timeout: 30,
        max_response_bytes: nil,
        compress: true,
        follow_redirects: false,
        max_redirects: 5,
        retries: 0,
        retry_delay: 0.1,
        cookies: false,
        auth: nil,
        middleware: []
      }.freeze

      UNSET = Object.new.freeze
      TLS_KEYS = [:ca_file, :ca_path, :cert_store, :cert, :key, :ciphers, :min_version,
                  :max_version, :verify_mode, :verify_hostname, :verify_depth].freeze
      @pool_mutex = Mutex.new
      @pid = Process.pid
      @pool = nil
      @pool_options = {}.freeze
      @operations = {}

      class << self
        def configure_pool(max_connections: 100, max_connections_per_origin: 10, idle_timeout: 30)
          values = [max_connections, max_connections_per_origin, idle_timeout]
          raise ArgumentError, 'pool limits must be positive' unless values.all? { |v| v.is_a?(Numeric) && v.finite? && v > 0 }
          raise ArgumentError, 'connection limits must be integers' unless values[0,2].all? { |v| v.is_a?(Integer) }
          reset_process
          @pool_mutex.synchronize do
            raise Error, 'configure_pool must precede use or follow shutdown' if @pool
            @pool_options = {max_connections: max_connections, max_connections_per_origin: max_connections_per_origin, idle_timeout: idle_timeout}.freeze
          end
          nil
        end

        # Cancel active requests, release all shared connections, and start a fresh
        # pool on the next request. Existing clients may be used after shutdown.
        def shutdown
          reset_process
          pool, operations = @pool_mutex.synchronize do
            previous = @pool
            @pool = nil
            [previous, @operations.keys]
          end
          operations.each(&:cancel)
          pool.shutdown if pool
          nil
        end

        def pool_stats
          reset_process
          @pool_mutex.synchronize { @pool ? @pool.stats : {connections: 0, connecting: 0, active: 0}.freeze }
        end

        private

        # Client.reset_process
        # Clientクラスが管理する共有資源をリセット
        def reset_process
          return if @pid == Process.pid
          @pool.shutdown if @pool
          @pool_mutex = Mutex.new
          @pool, @operations, @pid = nil, {}, Process.pid
        end

        # Client.register
        def register(operation)
          reset_process # => Client.reset_process

          @pool_mutex.synchronize do
            @operations[operation] = true
            # プロセス全体の共有プールを作成
            @pool ||= Pool.new(**@pool_options) # => Pool#initialize
          end
        end

        # Client.unregister
        def unregister(operation)
          @pool_mutex.synchronize { @operations.delete(operation) }
        end
      end

      attr_reader :cookie_jar

      # Client#initialize
      def initialize(base_url = nil, **options)
        # Client::DEFAULTSにない設定名があれば例外
        unknown = options.keys - DEFAULTS.keys
        raise ArgumentError, "unknown options: #{unknown.join(', ')}" unless unknown.empty?

        # デフォルトの初期値にoptionsをmergeして初期化
        @options = DEFAULTS.merge(options)
        @options[:headers] = Request.headers(@options[:headers]) # => Request.headers ()
        @options[:protocols] = Array(@options[:protocols]).dup.freeze

        # プロトコルが1つ以上ある、かつ含まれているプロトコル名が:http1か:http2であることを検証
        unless !@options[:protocols].empty? && (@options[:protocols] - [:http1, :http2]).empty?
          raise ArgumentError, 'protocols must contain :http1 and/or :http2'
        end

        # Client::TLS_KEYSにない設定名があれば例外
        unknown_tls = @options[:tls].keys - TLS_KEYS
        raise ArgumentError, "unknown TLS settings: #{unknown_tls.join(', ')}" unless unknown_tls.empty?

        # Client#snapshot -> Request#snapshot (設定をコピー)
        @options[:tls] = snapshot(@options[:tls])
        @options[:auth] = snapshot(@options[:auth])
        @options[:proxy] = snapshot(@options[:proxy])
        @options[:middleware] = @options[:middleware].dup.freeze

        # @optionsを検証
        validate_options(@options)
        @options.freeze
        @base_url = base_url && URI(base_url.to_s).freeze

        # ベースURLがある場合は、schemeがhttp / httpsであり、hostnameがあり、userinfoがないこと
        if @base_url && (!%w[http https].include?(@base_url.scheme) || !@base_url.hostname || @base_url.userinfo)
          raise ArgumentError, 'base_url must be an absolute HTTP(S) URL without userinfo'
        end

        # Cookieを保存する場所を決める
        @cookie_jar = options[:cookies].is_a?(CookieJar) ?
          options[:cookies] : (options[:cookies] ? CookieJar.new : nil)

        @mutex = Mutex.new # Clientの状態更新を排他制御するためのミューテックス
        @active = {}       # このClientで実行中のOperationを記録するためのハッシュ
        @closed = false    # Clientがクローズされたかどうか
        @pid = Process.pid # 現在のプロセスID (fork後にプロセスが変わったことを検出するためのもの)

        # 認証情報を送ってよい接続先の範囲
        @auth_origin = @base_url && [@base_url.scheme, @base_url.hostname.downcase, @base_url.port]

        @digest_mutex = Mutex.new # 複数のリクエストによるカウンタの同時更新を排他制御するためのミューテックス
        @digest_count = 0 # 認証に使うnonce countの元になるカウンタ

        # Client#buffered_getを利用できるかどうか
        @simple_get = @base_url && @base_url.scheme == 'http' && @options[:proxy].nil? &&
          DEFAULTS.all? { |key, value| key == :proxy || @options[key] == value }

        @get_templates = {} # Client#buffered_getで用いるリクエスト情報を保存するハッシュ
      end

      # Client#build_request
      def build_request(
        method,
        url = nil,
        headers: {},
        body: nil,
        json: UNSET, # => Client::UNSET (Object.new.freeze)
        form: nil,
        multipart: nil,
        params: nil,
        **options
      )
        # Client::DEFAULTSにない設定名があれば例外
        unknown = options.keys - DEFAULTS.keys
        raise ArgumentError, "unknown options: #{unknown.join(', ')}" unless unknown.empty?

        url = @base_url if url.nil?
        raise ArgumentError, 'URL is required' unless url

        # URLをURIオブジェクトへ変換
        uri = URI(url.to_s)
        uri = @base_url.merge(uri) if @base_url && !uri.absolute?

        # paramsが指定されていればURLのクエリ用にエンコード
        if params
          query = URI.encode_www_form(params)
          uri.query = [uri.query, query].compact.reject(&:empty?).join('&')
        end

        # ヘッダをまとめ、ボディの指定方法が重複していないかを確認
        headers = @options[:headers].merge(Request.headers(headers))
        json_given = !json.equal?(UNSET)
        specified = [body, form, multipart].count { |value| !value.nil? } + (json_given ? 1 : 0)
        raise ArgumentError, 'choose one of body, json, form, multipart' if specified > 1

        # ボディの指定方法に応じてbody, headersをセット
        if json_given
          body = JSON.generate(json)
          headers = headers.merge('content-type'=>['application/json'])
        elsif form
          body = URI.encode_www_form(form)
          headers = headers.merge('content-type'=>['application/x-www-form-urlencoded'])
        elsif multipart
          body = MultipartBody.new(multipart)
          headers = headers.merge('content-type'=>["multipart/form-data; boundary=#{body.boundary}"])
        end

        # ここまでで用意したuri, headers, body, 引数で受け取ったmethod, optionsを用いてRequest.new
        Request.new(method, uri, headers: headers, body: body, **options)
        # => Client::Request#initialize (lib/net/http/client/request.rb)
      end

      # Client#request
      def request(method, url = nil, **options, &block)
        if @simple_get &&
           !block &&
           options.empty? &&
           (method == :get || method == 'get' || method == 'GET') && # GETリクエスト
           url.is_a?(String) && url.start_with?('/') && !url.start_with?('//') # 別のホストを指定しうるURLではない

          return buffered_get(url) # => Client#buffered_get
        end

        req = build_request(method, url, **options) # => Client#build_request
        perform(req, &block) # => Client#perform
      end

      %w[head post put patch delete options trace].each do |verb|
        define_method(verb) { |url = nil, **options, &block| request(verb, url, **options, &block) }
      end

      # Client#get
      def get(url = nil, **options, &block)
        if @simple_get &&
           !block &&
           options.empty? &&
           url.is_a?(String) && url.start_with?('/') && !url.start_with?('//')

          buffered_get(url) # => Client#buffered_get
        else
          request(:get, url, **options, &block) # => Client#request
        end
      end

      # Client#stream
      def stream(method, url = nil, **options, &block)
        raise ArgumentError, 'stream requires a block' unless block
        request(method, url, **options, &block) # => Client#request
      end

      # Client#perform
      def perform(request, &block)
        if request.is_a?(Net::HTTPRequest) # 既存のNet::HTTPRequestオブジェクトの場合
          uri = request.uri || (@base_url && @base_url.merge(request.path))
          headers = request.to_hash
          body = request.body_stream || request.body

          if (form = request.instance_variable_get(:@body_data))
            # set_form defers serialization until sending. Snapshot it through
            # the shared body layer without mutating the caller's request.
            if request.content_type.to_s.casecmp('multipart/form-data').zero?
              body = MultipartBody.new(form, legacy_options: request.instance_variable_get(:@form_option) || {})
              headers['content-type'] = ["multipart/form-data; boundary=\"#{body.boundary}\""]
            else
              body = URI.encode_www_form(form)
              headers['content-type'] = ['application/x-www-form-urlencoded']
            end
            headers.delete('content-length')
          end

          # Net::HTTPRequestオブジェクトをもとにしてClient::Requestオブジェクトを作成する
          request = build_request(request.method, uri, headers: headers, body: body) # => Client#build_request
        end

        raise ArgumentError, 'expected Client::Request or Net::HTTPRequest' unless request.is_a?(Request)

        # Requestの設定でClientの設定を上書きする
        options = @options.merge(request.options)

        if request.options.key?(:middleware)
          # options[:middleware]は上書きでなく連結する
          options[:middleware] = @options[:middleware] + request.options[:middleware]
        end

        validate_options(options) # => Client#validate_options 設定を検証
        operation = Operation.new(options) # => Client::Operation#initialize (lib/net/http/client/runtime.rb)
        reset_after_fork # => Client#reset_after_fork

        @mutex.synchronize do
          raise ClosedError, 'client is closed' if @closed
          @active[operation] = true
        end

        # コネクションプールを取得
        pool = Client.send(:register, operation) # => Client.register

        begin # 実際の送信処理をmiddlewareでラップし、順に呼び出す
          terminal = proc { |req| execute(req, operation, pool, &block) } # => Client#execute WIP

          # middlewareの配列を最後の要素から順に登録する。middlewareは外部からAPI経由で渡せる
          options[:middleware].reverse_each do |middleware|
            downstream = terminal
            terminal = proc { |req| middleware.call(req, downstream) }
          end

          terminal.call(request) # Client#execute を呼び出す
        ensure
          operation.detach # Operationに登録したキャンセル用callbackをデタッチ
          @mutex.synchronize { @active.delete(operation) } # このClientインスタンスの実行中一覧からOperationを削除
          Client.send(:unregister, operation) # => Client.unregister
        end
      end

      def close
        reset_after_fork
        @mutex.synchronize { @closed = true }
        nil
      end
      def close!
        reset_after_fork
        operations = @mutex.synchronize { @closed = true; @active.keys }
        operations.each(&:cancel)
        nil
      end
      def closed?; @closed; end
      def inspect
        "#<#{self.class} closed=#{closed?}>"
      end

      private

      # Client#buffered_get TLSを利用しないHTTP通信でのGET
      # Reuse immutable URL/route preparation for the common buffered H1 GET.
      # The same shared pool, operation registration and cancellation rules apply.
      def buffered_get(url)
        reset_after_fork # => Client#reset_after_fork
        operation = Operation.new(@options) # => Client::Operation#initialize (lib/net/http/client/runtime.rb)

        template = @mutex.synchronize do
          raise ClosedError, 'client is closed' if @closed
          prepared = @get_templates[url] # テンプレートをキャッシュから取得

          # 例
          # @get_templates[url] = [
          #   request,                # Client::Request
          #   route_key,              # 接続を共有できるか判定するキー
          #   request.request_target  # 送信するパスとクエリ
          # ]

          unless prepared
            request = build_request(:get, url) # => Client#build_request
            prepared = [
              request,
              route_key(request, @options, nil), # => Client#route_key
              request.request_target.freeze
            ].freeze

            @get_templates.shift if @get_templates.size >= 64
            @get_templates[url.dup.freeze] = prepared
          end

          # Operationを実行中として登録する
          @active[operation] = true
          prepared
        end

        # コネクションプールを取得
        pool = Client.send(:register, operation) # => Client.register
        entry = slot = nil

        begin
          request, # GETを表すClient::Request
          key,     # 接続を共有できる条件をまとめたroute key
          target = template # パスとクエリ

          entry, # 接続のセッションなどを持つ接続プールのエントリ
          slot = # 予約を表す値
            pool.acquire( # => Client::Pool#acquire プールに対して接続の取得と予約の依頼
              key, # 再利用できる接続を探す条件
              operation, # 待機中に期限・キャンセルを確認するための情報
              origin: key[0] # 接続数をorigin単位で管理するための情報
            ) { ConnectionFactory.open(request, @options, operation, nil) } # => ConnectionFactory.open 接続をつくる

          # 取得した接続でGETを送信
          entry.session.buffered_get(target, operation) # => H1Session#buffered_get
        ensure
          operation.detach # Operationに登録したキャンセル用callbackをデタッチ
          pool.release(entry, slot) if entry # プールに接続を返却
          @mutex.synchronize { @active.delete(operation) } # このClientインスタンスの実行中一覧からOperationを削除
          Client.send(:unregister, operation) # => Client.unregister
        end
      end

      # Client#snapshot
      def snapshot(value)
        Request.snapshot(value)
      end

      # Client#validate_options
      def validate_options(options)
        unknown = options.keys - DEFAULTS.keys
        raise ArgumentError, "unknown options: #{unknown.join(', ')}" unless unknown.empty?

        protocols = options[:protocols]
        unless protocols.is_a?(Array) && !protocols.empty? && (protocols - [:http1, :http2]).empty?
          raise ArgumentError, 'protocols must contain :http1 and/or :http2'
        end

        unless options[:tls].is_a?(Hash) && (options[:tls].keys - TLS_KEYS).empty?
          raise ArgumentError, 'invalid TLS options'
        end

        auth = options[:auth]
        if auth &&
           !(auth.is_a?(Array) &&
             ((auth[0] == :bearer && auth.size == 2) || ([:basic,:digest].include?(auth[0]) && auth.size == 3)))
          raise ArgumentError, 'invalid authentication options'
        end

        unless options[:middleware].is_a?(Array) && options[:middleware].all? { |item| item.respond_to?(:call) }
          raise ArgumentError, 'middleware must be an array of callable objects'
        end

        [:open_timeout, :read_timeout, :write_timeout, :pool_timeout, :idle_timeout, :retry_delay].each do |name|
          value = options[name]
          unless value.is_a?(Numeric) && value.finite? && value > 0
            raise ArgumentError, "#{name} must be a positive finite number"
          end
        end

        [:timeout, :max_response_bytes].each do |name|
          value = options[name]
          if value && !(value.is_a?(Numeric) && value.finite? && value > 0)
            raise ArgumentError, "#{name} must be nil or positive"
          end
        end

        [:retries, :max_redirects].each do |name|
          unless options[name].is_a?(Integer) && options[name] >= 0
            raise ArgumentError, "#{name} must be a nonnegative integer"
          end
        end
      end

      # Client#reset_after_fork
      # Clientを作ったプロセスと現在のプロセスが同じかどうかを確認する
      def reset_after_fork
        return if @pid == Process.pid

        # 子プロセスの場合、親の実行中リクエストやロックをそのまま使うことはできないため、状態を作り直す
        @mutex, @active, @pid = Mutex.new, {}, Process.pid
        @digest_mutex = Mutex.new
      end

      # Client#proxy_for
      def proxy_for(uri, setting)
        proxy = setting == :ENV ? uri.find_proxy : setting
        return nil unless proxy

        proxy = URI(proxy.to_s)
        raise ArgumentError, 'proxy must be an HTTP URL' unless proxy.scheme == 'http' && proxy.hostname

        proxy
      end

      # Client#route_key
      def route_key(request, options, proxy)
        # Values are immutable snapshots or identity-bearing TLS objects. Request
        # credentials never enter this key; proxy credentials necessarily do.
        # [scheme・ホスト名・ポート, プロキシURL, 許可するHTTPプロトコル, TLS設定, 接続のkeep-alive設定]
        [request.origin, proxy && proxy.to_s, options[:protocols], options[:tls], options[:idle_timeout]].freeze
      end

      # Client#authorization
      def authorization(auth, request)
        return nil unless auth
        type, *args = auth
        case type
        when :basic then "Basic #{[args.join(':')].pack('m0')}"
        when :bearer then "Bearer #{args.fetch(0)}"
        when :digest then nil
        else raise ArgumentError, 'auth must be [:basic, user, password], [:bearer, token] or [:digest, user, password]'
        end
      end

      # Client#execute
      # 呼び出し側の例 execute(req, operation, pool, &block)
      #   initial   ... middlewareでラップしたRequest
      #   operation ... 今回の実行の設定・期限・キャンセルを管理するOperation
      #   pool      ... 共有コネクションプール
      def execute(initial, operation, pool)
        options = operation.options # timeout、認証、retry、redirectなどの設定を取得
        request = initial # request = 送信するリクエスト
        retries = redirects = 0
        challenged = false # challenged = Digest認証のチャレンジに対応済みかどうか
        auth_origin = @auth_origin || initial.origin # auth_origin = 設定された認証情報を送る基準のorigin

        # actionがnilになるまで = リクエストの再試行 / リダイレクト / 認証の再送 が不要になるまでループする
        loop do
          # キャンセル済みならCancelledError、タイムアウト済みならRequestTimeoutを発生させる
          operation.check! # => Client::Operation#check!

          headers = request.headers.dup

          # 圧縮が有効な場合かつAccept-Encodingが未設定の場合に設定
          headers['accept-encoding'] ||= ['gzip;q=1.0,deflate;q=0.6,identity;q=0.3'] if options[:compress]

          # 現在の送信先が認証の基準originと一致する場合、設定された認証情報からヘッダ値を作成
          if request.origin == auth_origin
            auth = authorization(options[:auth], request) #=> Client#authorization
            headers['authorization'] ||= [auth] if auth
          end

          # @cookie_jarがあるがRequestにCookieヘッダが明示されていない場合は、URLに合うCookie値を作成
          if @cookie_jar && !headers.key?('cookie')
            cookie = @cookie_jar.header(request.uri) # => Client::CookieJar#header
            headers['cookie'] = [cookie] unless cookie.empty?
          end

          attempt = request.with(headers: headers) # => Request#with 圧縮・認証・Cookieのヘッダを反映したRequest
          proxy = proxy_for(request.uri, options[:proxy]) # => Client#proxy_for 今回の送信先で利用するプロキシ
          key = route_key(attempt, options, proxy) # => Client#route_key 再利用できる接続を探すキー

          entry = nil # entry = 接続のセッションなどを持つ接続プールのエントリ
          reservation = nil # reservation = 予約を表す値
          response = nil
          action = nil # レスポンスを返す前に必要な次の処理を格納する
          visible = false # レスポンスを返すことができるかどうか

          begin
            entry, reservation = pool.acquire( # => Client::Pool#acquire プールに対して接続の取得と予約の依頼
              key,
              operation,
              origin: key[0] # 接続数をorigin単位で管理するための情報
            ) { ConnectionFactory.open(attempt, options, operation, proxy) } # => ConnectionFactory.open 接続を作成

            # WIP
            response = entry.session.exchange(attempt, operation, reservation) { |res|
              # => Client::Pool::Entry#session
              #      - Client::H1Session#exchange
              #      - Client::HTTP2::Session#exchange

              # CookieJarが有効ならレスポンスのSet-CookieヘッダからCookieを保存する
              @cookie_jar.store(request.uri, res) if @cookie_jar # => Client::CookieJar#store

              if res.code == '401' &&             # 認証が必要
                 !challenged &&                   # まだDigest認証のチャレンに応答していない
                 request.origin == auth_origin && # 認証情報を送ることができるoriginである
                 options[:auth] &&                # 認証設定がある
                 options[:auth][0] == :digest &&  #認証方式がDigest
                 request.replayable?              # ボディをもう一度読み出して再送可能

                # Authorizationヘッダの値を作成 -> 値がある場合
                if (digest = digest_authorization(res, attempt, options[:auth])) # => Client#digest_authorization
                  action = [:digest, digest]
                end

              elsif options[:follow_redirects] &&                 # 自動リダイレクトが有効
                    %w[301 302 303 307 308].include?(res.code) && # ステータスコードがリダイレクトを意図
                    res['location']                               # リダイレクト先を示すLocationヘッダがある

                # リダイレクト回数が上限に達していたら例外
                raise RedirectError, 'too many redirects' if redirects >= options[:max_redirects]

                action = [:redirect, res['location']]

              elsif retries < options[:retries] &&         # 再試行回数が上限未満
                    retryable?(request) &&                 # Clientが安全に再試行できることを判断できるRequest
                    %w[429 502 503 504].include?(res.code) # ステータスコードが再試行を意図

                delay = retry_after(res, options[:retry_delay])# => Client#retry_after
                action = [:retry, retry_after(res, delay]
              end

              if action # actionがある場合は、認証の再送・リダイレクト・再試行のいずれかが必要
                # Closing an unread response releases H1 or resets only this H2 stream.
              else
                visible = true
                block_given? ? yield(res) : res.read_body
              end
            }

          rescue IOError, EOFError, SystemCallError, Net::ReadTimeout, Net::WriteTimeout, Net::OpenTimeout => error
            # キャンセル済みならCancelledError、タイムアウト済みならRequestTimeoutを発生させる
            operation.check! # => Client::Operation#check!
            raise if visible || error.is_a?(PoolTimeout) || retries >= options[:retries] || !retryable?(request)

            action = [:retry, options[:retry_delay]]
          ensure
            operation.detach # Operationに登録したキャンセル用callbackをデタッチ

            # 予約を解放し、最終使用時刻の更新と閉じた接続を削除
            pool.release(entry, reservation) if entry # => Client::Pool#release
          end

          return response unless action
          case action[0]
          when :digest
            challenged = true
            request = request.with(headers: request.headers.merge('authorization'=>[action[1]]))
          when :redirect
            redirects += 1
            target = request.uri.merge(action[1])
            unless %w[http https].include?(target.scheme) && target.hostname && !target.userinfo
              raise RedirectError, 'redirect target must be an HTTP(S) URL without userinfo'
            end
            raise RedirectError, 'HTTPS to HTTP redirect rejected' if request.uri.scheme == 'https' && target.scheme != 'https'
            method = request.method
            body = request.body
            headers = request.headers.dup
            if response.code == '303' && method != 'HEAD' || %w[301 302].include?(response.code) && method == 'POST'
              method, body = 'GET', nil
              %w[content-type content-length transfer-encoding].each { |name| headers.delete(name) }
            elsif !request.replayable?
              raise RedirectError, 'redirect requires a replayable body'
            end
            if [target.scheme, target.hostname.downcase, target.port] != request.origin
              %w[authorization proxy-authorization cookie host].each { |name| headers.delete(name) }
            end
            request = request.with(method: method, uri: target, headers: headers, body: body)
          when :retry
            retries += 1
            until (remaining = action[1]) <= 0
              pause = [remaining, 0.05, operation.remaining].compact.min
              sleep(pause)
              operation.check!
              action[1] -= pause
            end
          end
        end
      end

      def retryable?(request)
        %w[GET HEAD PUT DELETE OPTIONS TRACE].include?(request.method) && request.replayable?
      end

      # Client#retry_after
      def retry_after(response, fallback)
        value = response['retry-after']
        return fallback unless value

        value.match?(/\A\d+\z/) ? value.to_i : [Time.httpdate(value) - Time.now, 0].max
      rescue ArgumentError
        fallback
      end

      # Client#digest_authorization
      # サーバのDigest認証チャレンジを読み、再送時に付与するAuthorizationヘッダの値を作る
      def digest_authorization(response, request, auth)
        challenge = (response.get_fields('www-authenticate') || []).find { |v| v.match?(/\ADigest\s+/i) }
        return nil unless challenge

        fields =
          challenge
            .sub(/\ADigest\s+/i, '')
            .scan(/([\w-]+)\s*=\s*(?:"((?:\\.|[^"\\])*)"|([^,\s]+))/)
            .each_with_object({}) { |(k,v,u), h| h[k.downcase] = (v.nil? ? u : v).to_s.gsub(/\\(.)/, '\\1') }

        realm, nonce = fields.values_at('realm', 'nonce')
        return nil unless realm && nonce

        algorithm = fields.fetch('algorithm', 'MD5')
        base = algorithm.sub(/-sess\z/i, '').upcase
        return nil unless %w[MD5 SHA-256 SHA-512-256].include?(base)

        digest =
          case base
          when 'SHA-512-256' then OpenSSL::Digest.new('SHA512-256')
          when 'SHA-256' then Digest::SHA256
          else  Digest::MD5
          end

        hash = proc { |text| digest.hexdigest(text) }
        qop = fields['qop'] && fields['qop'].split(/,\s*/).find { |v| v == 'auth' }

        return nil if fields['qop'] && !qop

        cnonce = SecureRandom.hex(16)
        count = @digest_mutex.synchronize { @digest_count += 1 }
        nc = format('%08x', count)
        ha1 = hash.call("#{auth[1]}:#{realm}:#{auth[2]}")

        session_algorithm = algorithm.match?(/-sess\z/i)
        ha1 = hash.call("#{ha1}:#{nonce}:#{cnonce}") if session_algorithm
        ha2 = hash.call("#{request.method}:#{request.request_target}")

        result = hash.call(qop ? "#{ha1}:#{nonce}:#{nc}:#{cnonce}:#{qop}:#{ha2}" : "#{ha1}:#{nonce}:#{ha2}")

        values = {username: auth[1], realm: realm, nonce: nonce, uri: request.request_target, response: result}
        values[:cnonce] = cnonce if qop || session_algorithm
        values[:opaque] = fields['opaque'] if fields['opaque']

        quote = proc { |v| '"' + v.to_s.gsub(/["\\]/) { |c| "\\#{c}" } + '"' }

        result = values.map { |k,v| "#{k}=#{quote.call(v)}" }
        result << "algorithm=#{algorithm}"
        result.concat(["qop=auth", "nc=#{nc}"]) if qop

        "Digest #{result.join(', ')}"
      end

      private_constant :DEFAULTS, :TLS_KEYS, :UNSET
    end
  end
end
```
