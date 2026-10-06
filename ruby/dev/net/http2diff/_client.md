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
        def reset_process
          return if @pid == Process.pid
          @pool.shutdown if @pool
          @pool_mutex = Mutex.new
          @pool, @operations, @pid = nil, {}, Process.pid
        end
        def register(operation)
          reset_process
          @pool_mutex.synchronize do
            @operations[operation] = true
            @pool ||= Pool.new(**@pool_options)
          end
        end
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

      def build_request(method, url = nil, headers: {}, body: nil, json: UNSET, form: nil, multipart: nil, params: nil, **options)
        unknown = options.keys - DEFAULTS.keys
        raise ArgumentError, "unknown options: #{unknown.join(', ')}" unless unknown.empty?
        url = @base_url if url.nil?
        raise ArgumentError, 'URL is required' unless url
        uri = URI(url.to_s)
        uri = @base_url.merge(uri) if @base_url && !uri.absolute?
        if params
          query = URI.encode_www_form(params)
          uri.query = [uri.query, query].compact.reject(&:empty?).join('&')
        end
        headers = @options[:headers].merge(Request.headers(headers))
        json_given = !json.equal?(UNSET)
        specified = [body, form, multipart].count { |value| !value.nil? } + (json_given ? 1 : 0)
        raise ArgumentError, 'choose one of body, json, form, multipart' if specified > 1
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
        Request.new(method, uri, headers: headers, body: body, **options)
      end

      # Client#request
      def request(method, url = nil, **options, &block)
        if @simple_get && !block && options.empty? && (method == :get || method == 'get' || method == 'GET') && url.is_a?(String) && url.start_with?('/') && !url.start_with?('//')
          return buffered_get(url)
        end
        perform(build_request(method, url, **options), &block)
      end

      %w[head post put patch delete options trace].each do |verb|
        define_method(verb) { |url = nil, **options, &block| request(verb, url, **options, &block) }
      end

      def get(url = nil, **options, &block)
        if @simple_get && !block && options.empty? && url.is_a?(String) && url.start_with?('/') && !url.start_with?('//')
          buffered_get(url)
        else
          request(:get, url, **options, &block)
        end
      end

      # Client#stream
      def stream(method, url = nil, **options, &block)
        raise ArgumentError, 'stream requires a block' unless block
        request(method, url, **options, &block) # => Client#request
      end

      def perform(request, &block)
        if request.is_a?(Net::HTTPRequest)
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
          request = build_request(request.method, uri, headers: headers, body: body)
        end
        raise ArgumentError, 'expected Client::Request or Net::HTTPRequest' unless request.is_a?(Request)
        options = @options.merge(request.options)
        if request.options.key?(:middleware)
          options[:middleware] = @options[:middleware] + request.options[:middleware]
        end
        validate_options(options)
        operation = Operation.new(options)
        reset_after_fork
        @mutex.synchronize do
          raise ClosedError, 'client is closed' if @closed
          @active[operation] = true
        end
        pool = Client.send(:register, operation)
        begin
          terminal = proc { |req| execute(req, operation, pool, &block) }
          options[:middleware].reverse_each do |middleware|
            downstream = terminal
            terminal = proc { |req| middleware.call(req, downstream) }
          end
          terminal.call(request)
        ensure
          operation.detach
          @mutex.synchronize { @active.delete(operation) }
          Client.send(:unregister, operation)
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

      # Reuse immutable URL/route preparation for the common buffered H1 GET.
      # The same shared pool, operation registration and cancellation rules apply.
      def buffered_get(url)
        reset_after_fork
        operation = Operation.new(@options)
        template = @mutex.synchronize do
          raise ClosedError, 'client is closed' if @closed
          prepared = @get_templates[url]
          unless prepared
            request = build_request(:get, url)
            prepared = [request, route_key(request, @options, nil), request.request_target.freeze].freeze
            @get_templates.shift if @get_templates.size >= 64
            @get_templates[url.dup.freeze] = prepared
          end
          @active[operation] = true
          prepared
        end
        pool = Client.send(:register, operation)
        entry = slot = nil
        begin
          request, key, target = template
          entry, slot = pool.acquire(key, operation, origin: key[0]) { ConnectionFactory.open(request, @options, operation, nil) }
          entry.session.buffered_get(target, operation)
        ensure
          operation.detach
          pool.release(entry, slot) if entry
          @mutex.synchronize { @active.delete(operation) }
          Client.send(:unregister, operation)
        end
      end

      # Client#snapshot
      def snapshot(value)
        Request.snapshot(value)
      end

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
        if auth && !(auth.is_a?(Array) && ((auth[0] == :bearer && auth.size == 2) || ([:basic,:digest].include?(auth[0]) && auth.size == 3)))
          raise ArgumentError, 'invalid authentication options'
        end
        unless options[:middleware].is_a?(Array) && options[:middleware].all? { |item| item.respond_to?(:call) }
          raise ArgumentError, 'middleware must be an array of callable objects'
        end
        [:open_timeout, :read_timeout, :write_timeout, :pool_timeout, :idle_timeout, :retry_delay].each do |name|
          value = options[name]
          raise ArgumentError, "#{name} must be a positive finite number" unless value.is_a?(Numeric) && value.finite? && value > 0
        end
        [:timeout, :max_response_bytes].each do |name|
          value = options[name]
          raise ArgumentError, "#{name} must be nil or positive" if value && !(value.is_a?(Numeric) && value.finite? && value > 0)
        end
        [:retries, :max_redirects].each do |name|
          raise ArgumentError, "#{name} must be a nonnegative integer" unless options[name].is_a?(Integer) && options[name] >= 0
        end
      end

      def reset_after_fork
        return if @pid == Process.pid
        @mutex, @active, @pid = Mutex.new, {}, Process.pid
        @digest_mutex = Mutex.new
      end

      def proxy_for(uri, setting)
        proxy = setting == :ENV ? uri.find_proxy : setting
        return nil unless proxy
        proxy = URI(proxy.to_s)
        raise ArgumentError, 'proxy must be an HTTP URL' unless proxy.scheme == 'http' && proxy.hostname
        proxy
      end

      def route_key(request, options, proxy)
        # Values are immutable snapshots or identity-bearing TLS objects. Request
        # credentials never enter this key; proxy credentials necessarily do.
        [request.origin, proxy && proxy.to_s, options[:protocols], options[:tls], options[:idle_timeout]].freeze
      end

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

      def execute(initial, operation, pool)
        options = operation.options
        request = initial
        retries = redirects = 0
        challenged = false
        auth_origin = @auth_origin || initial.origin
        loop do
          operation.check!
          headers = request.headers.dup
          headers['accept-encoding'] ||= ['gzip;q=1.0,deflate;q=0.6,identity;q=0.3'] if options[:compress]
          if request.origin == auth_origin
            auth = authorization(options[:auth], request)
            headers['authorization'] ||= [auth] if auth
          end
          if @cookie_jar && !headers.key?('cookie')
            cookie = @cookie_jar.header(request.uri)
            headers['cookie'] = [cookie] unless cookie.empty?
          end
          attempt = request.with(headers: headers)
          proxy = proxy_for(request.uri, options[:proxy])
          key = route_key(attempt, options, proxy)
          entry = reservation = nil
          response = nil
          action = nil
          visible = false
          begin
            entry, reservation = pool.acquire(key, operation, origin: key[0]) { ConnectionFactory.open(attempt, options, operation, proxy) }
            response = entry.session.exchange(attempt, operation, reservation) do |res|
              @cookie_jar.store(request.uri, res) if @cookie_jar
              if res.code == '401' && !challenged && request.origin == auth_origin && options[:auth] && options[:auth][0] == :digest && request.replayable?
                if (digest = digest_authorization(res, attempt, options[:auth]))
                  action = [:digest, digest]
                end
              elsif options[:follow_redirects] && %w[301 302 303 307 308].include?(res.code) && res['location']
                raise RedirectError, 'too many redirects' if redirects >= options[:max_redirects]
                action = [:redirect, res['location']]
              elsif retries < options[:retries] && retryable?(request) && %w[429 502 503 504].include?(res.code)
                action = [:retry, retry_after(res, options[:retry_delay])]
              end
              if action
                # Closing an unread response releases H1 or resets only this H2 stream.
              else
                visible = true
                block_given? ? yield(res) : res.read_body
              end
            end
          rescue IOError, EOFError, SystemCallError, Net::ReadTimeout, Net::WriteTimeout, Net::OpenTimeout => error
            operation.check!
            raise if visible || error.is_a?(PoolTimeout) || retries >= options[:retries] || !retryable?(request)
            action = [:retry, options[:retry_delay]]
          ensure
            operation.detach
            pool.release(entry, reservation) if entry
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
      def retry_after(response, fallback)
        value = response['retry-after']
        return fallback unless value
        value.match?(/\A\d+\z/) ? value.to_i : [Time.httpdate(value) - Time.now, 0].max
      rescue ArgumentError
        fallback
      end
      def digest_authorization(response, request, auth)
        challenge = (response.get_fields('www-authenticate') || []).find { |v| v.match?(/\ADigest\s+/i) }
        return nil unless challenge
        fields = challenge.sub(/\ADigest\s+/i, '').scan(/([\w-]+)\s*=\s*(?:"((?:\\.|[^"\\])*)"|([^,\s]+))/).each_with_object({}) do |(k,v,u), h|
          h[k.downcase] = (v.nil? ? u : v).to_s.gsub(/\\(.)/, '\\1')
        end
        realm, nonce = fields.values_at('realm', 'nonce')
        return nil unless realm && nonce
        algorithm = fields.fetch('algorithm', 'MD5')
        base = algorithm.sub(/-sess\z/i, '').upcase
        return nil unless %w[MD5 SHA-256 SHA-512-256].include?(base)
        digest = base == 'SHA-512-256' ? OpenSSL::Digest.new('SHA512-256') : (base == 'SHA-256' ? Digest::SHA256 : Digest::MD5)
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
        'Digest ' + result.join(', ')
      end
      private_constant :DEFAULTS, :TLS_KEYS, :UNSET
    end
  end
end
```
