require "socket"
require "resolv"
require "openssl"
require "ipaddr"
require "http/2"

require_relative "./getaddrinfo"

DEBUG = true

class HTTPClient
  AAAA_TYPE  = Resolv::DNS::Resource::IN::AAAA
  A_TYPE     = Resolv::DNS::Resource::IN::A
  HTTPS_TYPE = Resolv::DNS::Resource::IN::HTTPS
  NAT64_PREFIX_RESULT = :nat64_prefix_detected

  NAMESERVER = ["127.0.0.1", 5300]
  HOST = "localhost"
  HTTPS_PORT = 8443
  HTTP_PORT = 8080
  RESOLUTION_DELAY = 0.05
  CONNECTION_ATTEMPT_DELAY = 0.25

  def self.run(**options)
    self.new(**options).run
  end

  def initialize(ipv4_connectivity: nil, ipv6_connectivity: nil)
    # 通信方式
    @use_ssl = ARGV[0] == "https"
    # オリジンのポート番号
    @port = @use_ssl ? HTTPS_PORT : HTTP_PORT

    # IPv4 / IPv6接続性
    @ipv4_reachable = ipv4_connectivity
    @ipv6_reachable = ipv6_connectivity
    # IPv4 / IPv6接続性に応じて問い合わせるDNSレコード種別
    @record_types = record_types

    # DNSリゾルバ
    @resolver = Resolv::DNS.new(nameserver_port: [NAMESERVER], raise_timeout_errors: true)
    # NAT64 prefix探索
    @nat64_discovery = NAT64PrefixDiscovery.new(resolver: @resolver)

    # 名前解決完了通知・解決結果チャネル
    @network_query_result_channel = NetworkQueryResultChannel.new
    # 名前解決スレッド管理リスト
    @hostname_resolution_threads = []

    # NAT64 prefix検出後にAレコードを問い合わせるホスト名のリスト
    @nat64_a_query_hostnames = []
    # IPv6-onlyの環境では、NAT64 prefixを検出してアドレス合成が可能になった後で
    # まとめてAレコードのDNS問い合わせを行う。
    # アドレス合成が可能かどうかが不明な間は、@nat64_a_query_hostnamesに対象のホスト名を保存しておく必要がある。

    # アドレスリスト
    @connection_planner = ConnectionPlanner.new(@record_types, self, origin_port: @port)

    # 接続処理中のTCPSocket
    @tcp_connecting_sockets = {}  # TCPSocket => [SSLContext, Addrinfo]
    # TLSハンドシェイク中のSSLSocket
    @tls_handshaking_sockets = {} # SSLSocket => :read / :write

    # HTTPリクエストに使用するソケット
    @tcp_connected_socket = nil # HTTP用のTCPソケット
    @tls_connected_socket = nil # HTTPS用のSSLソケット

    # 最初の接続試行を開始したかどうか
    @first_connection_attempted = false

    # 各待機時間の終了時刻
    @resolution_delay_expires_at = nil
    @connection_attempt_delay_expires_at = nil
  end

  def run
    now = current_clock_time

    # アドレス合成が必要な場合、非同期でNAT64 prefixを取得
    resolve_nat64_prefix_asynchronously! if address_synthesis_needed?
    # => HTTPClient#address_synthesis_needed?
    # => HTTPClient#resolve_nat64_prefix_asynchronously

    @record_types.each do |type|
      # 非同期で名前解決を実行
      resolve_hostname_asynchronously!(type) # => HTTPClient#resolve_hostname_asynchronously!
    end

    count = 0 if DEBUG
    last_error = nil

    loop do
      count += 1 if DEBUG

      puts "[DEBUG] #{count}: ** Check for readying to connect **" if DEBUG
      puts "[DEBUG] #{count}: @connection_planner #{@connection_planner.instance_variable_get(:@connection_plans)}" if DEBUG
      puts "[DEBUG] #{count}: resolution_delay_expires_at #{@resolution_delay_expires_at}" if DEBUG

      # 接続可能な場合
      if @connection_planner.connection_target_available?
         && !@resolution_delay_expires_at
         && !@connection_attempt_delay_expires_at

        @first_connection_attempted = true # 最初の接続試行へ進んだことを記録
        ctx, address, _hostname, port = @connection_planner.next_connection_target
        # => HTTPClient::ConnectionPlanner#next_connection_target
        addrinfo = Addrinfo.tcp(address.to_s, port)

        if !@use_ssl && # HTTP接続
           !@connection_planner.connection_target_available? && # 選択可能な未試行アドレスがない
           @tcp_connecting_sockets.empty? && # 進行中のTCP接続がない
           !@network_query_result_channel.pending? # 未回収の名前解決・NAT64検出結果がない

          begin
            @tcp_connected_socket = addrinfo.connect # ブロッキング接続 (TCP)
            break
          rescue SystemCallError => e
            last_error = e
            raise last_error
          end

        else
          socket = Socket.new(addrinfo.afamily, Socket::SOCK_STREAM)

          begin
            socket.connect_nonblock(addrinfo) # ノンブロッキング接続 (TCP)

            # 以下は即座に接続が完了した場合
            if @use_ssl # HTTPS接続
              if (error = nonblocking_connect_with_tls(socket, ctx))
                # => HTTPClient#nonblocking_connect_with_tls TLS接続をノンブロッキングで開始

                last_error = error
                next
              end

              break if @tls_connected_socket # 即座にTLS接続完了した場合

              @connection_attempt_delay_expires_at = now + CONNECTION_ATTEMPT_DELAY
            else
              @tcp_connected_socket = socket
              break
            end

          rescue IO::WaitWritable
            @connection_attempt_delay_expires_at = now + CONNECTION_ATTEMPT_DELAY
            @tcp_connecting_sockets[socket] = [ctx, addrinfo]
          rescue SystemCallError => e
            socket.close
            last_error = e
            # この時点で待機対象のIOがない場合無期限に待機する可能性があるため、
            # 未試行の候補がある場合は待機せずに次のアドレスを試す
            next if @connection_planner.connection_target_available?
          end
        end
      end

      puts "[DEBUG] #{count}: resolution_delay_expires_at #{@resolution_delay_expires_at || 'nil'}" if DEBUG
      puts "[DEBUG] #{count}: connection_attempt_delay_expires_at #{@connection_attempt_delay_expires_at || 'nil'}" if DEBUG

      ends_at =
        if @connection_planner.connection_target_available?
          @resolution_delay_expires_at || @connection_attempt_delay_expires_at
        else
          Float::INFINITY
        end

      puts "[DEBUG] #{count}: ends_at #{ends_at || 'nil'}" if DEBUG

      puts "[DEBUG] #{count}: ** Start to wait **" if DEBUG
      puts "[DEBUG] #{count}: IO.select(#{@network_query_result_channel.notifier}, #{@tcp_connecting_sockets}, nil, 0)" if DEBUG
      puts "[DEBUG] #{count}: connection_attempt_delay_expires_at #{@connection_attempt_delay_expires_at || 'nil'}" if DEBUG

      # 読み取り可能になるまで待機するFDs
      #  - 名前解決が完了したこと / NAT64 prefix検出が完了したこと
      #  - TLSハンドシェイク中に読み取り待ちになったこと
      waiting_rfds =
        (@network_query_result_channel.notifier || []) +
        @tls_handshaking_sockets.select { |_, direction| direction == :read }.keys

      # 書き込み可能になるまで待機するFDs
      #   - TCP接続が完了したこと
      #   - TLSハンドシェイク中に書き込み待ちになったこと
      waiting_wfds =
        @tcp_connecting_sockets.keys +
        @tls_handshaking_sockets.select { |_, direction| direction == :write }.keys

      # 待機対象のFDがない場合
      #   名前解決 / NAT64 prefix検出の結果をすべて回収済み (= @network_query_result_channel.notifierがclose済み)
      #   かつTCP接続中 / TLSハンドシェイク中のソケットがない場合
      if waiting_rfds.empty? && waiting_wfds.empty?
        # No delay remains: try the next connection target without waiting for IO.
        next if ends_at.nil? # 未試行の候補があり、待機期限が設定されていない場合は次のループへ

        if ends_at == Float::INFINITY # 未試行の候補がない場合
          raise last_error || SocketError.new("no addresses resolved for #{HOST}")
        end

        # 未試行の候補があり、待機期限が設定されている場合はifを抜けてIO.selectへ進む
      end

      readable_fds, writable_fds, _ = IO.select(
        waiting_rfds, waiting_wfds, nil, second_to_timeout(current_clock_time, ends_at),
      )

      now = current_clock_time
      @resolution_delay_expires_at = nil if expired?(now, @resolution_delay_expires_at)
      @connection_attempt_delay_expires_at = nil if expired?(now, @connection_attempt_delay_expires_at)

      puts "[DEBUG] #{count}: ** Check for writable_fds **" if DEBUG
      puts "[DEBUG] #{count}: writable_fds #{writable_fds || 'nil'}" if DEBUG
      puts "[DEBUG] #{count}: tcp_connecting_sockets #{@tcp_connecting_sockets}" if DEBUG

      # 書き込み可能なソケットをTLSハンドシェイク中のものとTCP接続中のものにわける
      ssl_writable_sockets, tcp_writable_sockets = (writable_fds || []).partition {
        @tls_handshaking_sockets.key?(it)
      }

      if tcp_writable_sockets.any? # TCP接続中のソケットがある場合
        while (writable_socket = tcp_writable_sockets.pop)
          is_connected = (
            sockopt = writable_socket.getsockopt(Socket::SOL_SOCKET, Socket::SO_ERROR)
            sockopt.int.zero?
          )

          if is_connected
            ctx, _ = @tcp_connecting_sockets.delete(writable_socket)

            if @use_ssl
              if (error = nonblocking_connect_with_tls(writable_socket, ctx))
                # => HTTPClient#nonblocking_connect_with_tls TLS接続をノンブロッキングで開始
                last_error = error
                @connection_attempt_delay_expires_at = nil
              end

              break if @tls_connected_socket # 即座にTLS接続完了した場合
            else
              @tcp_connected_socket = writable_socket
              break
            end

          else
            _, failed_ai = @tcp_connecting_sockets.delete writable_socket
            writable_socket.close
            ip_address = failed_ai.ipv6? ? "[#{failed_ai.ip_address}]" : failed_ai.ip_address
            last_error = SystemCallError.new("connect(2) for #{ip_address}:#{failed_ai.ip_port}", sockopt.int)

            if tcp_writable_sockets.any? || @tcp_connecting_sockets.any? || @tls_handshaking_sockets.any?
              # Try other writable socket
            elsif @connection_planner.connection_target_available? || @network_query_result_channel.pending?
              @connection_attempt_delay_expires_at = nil
            else
              raise last_error
            end

          end
        end
      end

      # 読み込み可能なソケットをTLSハンドシェイクで読み込み可能になったものと名前解決が終わったもので分ける
      ssl_ready_sockets, hostname_resolved = (readable_fds || []).partition {
        @tls_handshaking_sockets.key?(it)
      }

      # TLSハンドシェイク中のすべてのソケット
      (ssl_ready_sockets + ssl_writable_sockets).uniq.each do |ssl_socket|
        break if @tls_connected_socket # 接続が完了したものがあればbreak

        if (error = advance_tls_handshake(ssl_socket)) # => HTTPClient#advance_tls_handshake
          # HTTPClient#advance_tls_handshakeのなかでconnect_nonblockを再び呼び、進行状況を確認
          last_error = error
          @connection_attempt_delay_expires_at = nil
        end
      end

      if last_error && !@tcp_connected_socket && !@tls_connected_socket &&
          @tls_handshaking_sockets.empty? && @tcp_connecting_sockets.empty? &&
          !@connection_planner.connection_target_available? && !@network_query_result_channel.pending?
        raise last_error
      end

      puts "[DEBUG] #{count}: ** Check for hostname resolution finish **" if DEBUG
      puts "[DEBUG] #{count}: hostname_resolved #{hostname_resolved}" if DEBUG
      if hostname_resolved.any? # 読み込み可能なデータがある場合
        while (result = @network_query_result_channel.get) # 結果のうち先頭要素を取り出す
          raise result.error if result.unexpected_error?

          if result.type == NAT64_PREFIX_RESULT # NAT64 prefixを検出した場合
            resolve_hostname_with_nat64_prefix_asynchronously!(result.success? ? result.records.first : nil)
            # result.records.first = 検出したNAT64 prefix
            # => HTTPClient#resolve_hostname_with_nat64_prefix_asynchronously!

          else # HTTPS / AAAA / A の名前解決結果を取得した場合
            @connection_planner.add(result) # => HTTPClient::ConnectionPlanner#add
            last_error = result.error unless result.success?

          end
        end

        # NAT64 prefix検出済み / すべての名前解決結果を回収済みなら通知用パイプを閉じる
        @network_query_result_channel.close_if_done

        # アドレス候補がある
        if @connection_planner.connection_target_available?
          # => HTTPClient::ConnectionPlanner#connection_target_available?

          # HTTPS RRと優先ファミリを解決済み
          if @connection_planner.resolved?(HTTPS_TYPE) &&
             @connection_planner.resolved?(@connection_planner.preferred_type)

            puts "[DEBUG] #{count}: Ready to start connecting" if DEBUG
            @resolution_delay_expires_at = nil # Resolution Delayを解除

          elsif @resolution_delay_expires_at.nil? && !@first_connection_attempted
            # Resolution Delay未設定かつ初回接続前
            puts "[DEBUG] #{count}: Resolution Delay is ready" if DEBUG
            @resolution_delay_expires_at = now + RESOLUTION_DELAY

          end
        end
      end

      puts "------------------------" if DEBUG

      break if @tcp_connected_socket || @tls_connected_socket
    end

    cancel_pending_operations

    socket = @tls_connected_socket || @tcp_connected_socket
    request(socket)
  ensure
    cancel_pending_operations
    close_socket(@tls_connected_socket)
    close_socket(@tcp_connected_socket)
  end

  # HTTPClient#resolve_hostname_asynchronously!
  def resolve_hostname_asynchronously!(type, hostname = HOST)
    if address_synthesis_needed? # => HTTPClient#address_synthesis_needed? IPv6 onlyの場合
      # HTTPS RR以外の問い合わせ、かつ解決対象のホスト名が未登録の場合
      if [AAAA_TYPE, A_TYPE].include?(type) && !@nat64_a_query_hostnames.include?(hostname)
        @nat64_a_query_hostnames << hostname
      end
    end

    # 名前解決中のスレッド数をカウントアップ
    @network_query_result_channel.expect_result # => HTTPClient::NetworkQueryResultChannel#expect_result

    thread = Thread.new(type) do |type|
      records =
        if hostname == HOST && [AAAA_TYPE, A_TYPE].include?(type) # 最初のA/AAAA問い合わせ
          # getaddtinfoで名前解決する
          initial_getresources(type) # => HTTPClient#initial_getresources
          # HTTPS RRが返したホスト名に関してはDNSの設定に基づいて解決する
        else
          # DNS問い合わせする
          @resolver.getresources(hostname, type)
        end

      @network_query_result_channel.add(type, hostname, records:) # => HTTPClient::NetworkQueryResultChannel#add
    rescue => e
      @network_query_result_channel.add(type, hostname, error: e)
    end

    Thread.pass
    @hostname_resolution_threads.push(thread)
  end

  private

  # HTTPClient#resolve_nat64_prefix_asynchronously!
  def resolve_nat64_prefix_asynchronously!
    # Keep the result notifier open even if all destination queries finish first.
    @network_query_result_channel.expect_result # => HTTPClient::NetworkQueryResultChannel#expect_result↲

    thread = Thread.new do
      prefix = detect_nat64_prefix! # => HTTPClient#detect_nat64_prefix!
      @network_query_result_channel.add(NAT64_PREFIX_RESULT, "ipv4only.arpa", records: [prefix])
      # => HTTPClient::NetworkQueryResultChannel#add
    rescue => e
      @network_query_result_channel.add(NAT64_PREFIX_RESULT, "ipv4only.arpa", error: e)
    end

    Thread.pass
    @hostname_resolution_threads.push(thread)
  end

  # HTTPClient#resolve_hostname_with_nat64_prefix_asynchronously!
  def resolve_hostname_with_nat64_prefix_asynchronously!(prefix)
    return unless prefix

    # 取得したNAT64 prefixを保持する
    @connection_planner.nat64_prefix = prefix # => HTTPClient::ConnectionPlanner#nat64_prefix=
    # 問い合わせ種別にAを追加
    @record_types << A_TYPE unless @record_types.include?(A_TYPE)

    # @nat64_a_query_hostnames = NAT64 prefix検出後にAレコードを問い合わせるホスト名のリスト
    @nat64_a_query_hostnames.each do |hostname|
      # 取得したNAT64 prefixを合成しつつAレコードのDNS問い合わせを開始する
      resolve_hostname_asynchronously!(A_TYPE, hostname) # => HTTPClient#resolve_hostname_asynchronously!
    end
  end

  def request(socket)
    protocol = @use_ssl ? socket.alpn_protocol : nil

    case protocol
    when "h2"
      request_http2(socket)
    when nil, "http/1.1"
      request_http1(socket)
    else
      raise IOError, "unsupported negotiated ALPN: #{protocol}"
    end
  end

  def request_http1(socket)
    request_message = "GET / HTTP/1.1\r\nHost: #{HOST}:#{@port}\r\nConnection: close\r\n\r\n"
    socket.write request_message

    response_message = socket.read
    header_section, body = response_message.split("\r\n\r\n", 2)
    status_line = header_section.split("\r\n", 2).first

    puts status_line
    puts body
  end

  def request_http2(socket)
    connection = HTTP2::Client.new
    connection.on(:frame) { |bytes| socket.write(bytes) }

    stream = connection.new_stream
    status = nil
    body = "".b
    completed = false
    stream_error = nil
    goaway_error = nil

    stream.on(:headers) do |headers|
      response_status = headers.to_h[":status"]
      status = response_status if response_status && !response_status.start_with?("1")
    end

    stream.on(:data) { |chunk| body << chunk }

    stream.on(:close) do |error|
      stream_error = error
      completed = true
    end

    connection.on(:goaway) do |last_stream, error, _payload|
      next if completed

      if error != :no_error || stream.id > last_stream
        goaway_error ||= IOError.new("HTTP/2 GOAWAY: #{error}, last_stream=#{last_stream}, stream=#{stream.id}")
      end
    end

    stream.headers({
      ":method"    => "GET",
      ":scheme"    => "https",
      ":authority" => "#{HOST}:#{@port}",
      ":path"      => "/",
    }, end_stream: true)

    until completed || goaway_error
      connection << socket.readpartial(16_384)
    end

    raise goaway_error if goaway_error
    raise IOError, "HTTP/2 stream failed: #{stream_error}" if stream_error
    raise IOError, "HTTP/2 response missing final status" unless status

    puts "HTTP/2 #{status}"
    puts body
  end

  def close_socket(socket)
    socket.close if socket && !socket.closed?
  rescue IOError, SystemCallError, OpenSSL::SSL::SSLError
    # Continue cleanup without replacing the original connection/request error.
    nil
  end

  def cancel_pending_operations
    [@tcp_connecting_sockets, @tls_handshaking_sockets].each do |connections|
      connections.each_key do |socket|
        close_socket(socket)
      end
      connections.clear
    end

    @hostname_resolution_threads.each(&:exit)
    @hostname_resolution_threads.each(&:join)
    @network_query_result_channel.close_all
  end

  # HTTPClient#initial_getresources
  def initial_getresources(type)
    family = type == AAAA_TYPE ? Socket::AF_INET6 : Socket::AF_INET

    Addrinfo.getaddrinfo(HOST, @port, family, :STREAM).filter_map {
      type.new(it.ip_address) if !it.ipv6_linklocal?
    }.uniq
  end

  def record_types
    if ipv6_reachable? && ipv4_reachable?
      [HTTPS_TYPE, AAAA_TYPE, A_TYPE]
    elsif ipv6_reachable?
      [HTTPS_TYPE, AAAA_TYPE]
    elsif ipv4_reachable?
      [HTTPS_TYPE, A_TYPE]
    else
      raise "no network connectivity"
    end
  end

  # HTTPClient#address_synthesis_needed?
  # アドレス合成が必要? (IPv6の接続性があり、IPv4の接続性がない)
  def address_synthesis_needed?
    ipv6_reachable? && !ipv4_reachable?
    # => HTTPClient#ipv6_reachable?
    # => HTTPClient#ipv4_reachable?
  end

  # HTTPClient#ipv4_reachable?
  def ipv4_reachable?
    # 明示的な設定があれば or すでに取得済みならそれを利用
    return @ipv4_reachable if !@ipv4_reachable.nil?

    @ipv4_reachable =
      begin
        socket = UDPSocket.new(Socket::AF_INET)

        # 宛先を8.8.8.8へ設定 -> システムが経路に応じて送信元IPv4アドレスとポート番号を割り当てる
        socket.connect("8.8.8.8", 443)
        # UDPはハンドシェイクを行わないので、UDPSocket#connectを実行した時点では実際に送信は行わない

        # システムが選択した送信元アドレスをビット演算できる整数に変換
        n = IPAddr.new(socket.local_address.ip_address).to_i

        # 送信元アドレスが次のいずれにも該当しない = IPv4接続性あり
        #   - 0.0.0.0 未定義アドレス
        #   - 127.0.0.0/8 ループバックアドレス
        #   - 169.254.0.0/16 リンクローカルアドレス
        n != 0 && (n & 0xff000000) != 0x7f000000 && (n & 0xffff0000) != 0xa9fe0000
      rescue SystemCallError, SocketError
        false
      ensure
        socket&.close
      end
  end

  # HTTPClient#ipv6_reachable?
  def ipv6_reachable?
    # 明示的な設定があれば or すでに取得済みならそれを利用
    return @ipv6_reachable if !@ipv6_reachable.nil?

    @ipv6_reachable =
      begin
        socket = UDPSocket.new(Socket::AF_INET6)

        # 宛先を2001:4860:4860::8888へ設定 -> システムが経路に応じて送信元IPv6アドレスとポート番号を割り当てる
        socket.connect("2001:4860:4860::8888", 443)
          # UDPはハンドシェイクを行わないので、UDPSocket#connectを実行した時点では実際に送信は行わない

        n = IPAddr.new(socket.local_address.ip_address).to_i
        # 送信元アドレスが次のいずれにも該当しない = IPv6接続性あり
        #   - :: 未定義アドレス
        #   - ::1 ループバックアドレス
        #   - fe80::/10 リンクローカルアドレス
        n != 0 && n != 1 && (n >> 118) != 0x3fa
      rescue SystemCallError, SocketError
        false
      ensure
        socket&.close
      end
  end

  # HTTPClient#detect_nat64_prefix!
  # NAT64 prefixを取得
  def detect_nat64_prefix!
    @nat64_discovery.discover! # => NAT64PrefixDiscovery#discover!
  rescue Resolv::ResolvError, Resolv::ResolvTimeout
    nil
  end

  # HTTPClient#nonblocking_connect_with_tls
  def nonblocking_connect_with_tls(tcp_socket, ctx)
    ssl_socket = OpenSSL::SSL::SSLSocket.new(tcp_socket, ctx)
    ssl_socket.sync_close = true
    # RFC 9460 Section 9.4: SNI identifies the origin, not the TargetName.
    # TLSハンドシェイクで送るSNIのホスト名を設定
    # 接続先がHTTPSレコードから得た別のTargetNameであってもSNIには元のアクセス先であるHOSTを指定する
    # (接続先のサーバが変わっても利用したいWebサイトの名前は変わらない)
    ssl_socket.hostname = HOST

    advance_tls_handshake(ssl_socket) # => HTTPClient#advance_tls_handshake
  rescue OpenSSL::SSL::SSLError, SystemCallError => e
    close_socket(ssl_socket)
    close_socket(tcp_socket)
    e
  end

  # HTTPClient#advance_tls_handshake
  # Return nil on success or IO wait, and the exception on failure.
  def advance_tls_handshake(ssl_socket)
    ssl_socket.connect_nonblock

    # connect_nonblockが例外を送出せずに戻った場合、TLS接続完了済み
    @tls_handshaking_sockets.delete(ssl_socket)
    @tls_connected_socket = ssl_socket
    nil
  rescue IO::WaitReadable # ハンドシェイク中、メッセージを送信したいが送信バッファに空きがなくまだ書き込めない
    @tls_handshaking_sockets[ssl_socket] = :read
    nil
  rescue IO::WaitWritable # ハンドシェイク中、サーバからの応答がまだ届いていない
    @tls_handshaking_sockets[ssl_socket] = :write
    nil
  rescue OpenSSL::SSL::SSLError, SystemCallError => e
    @tls_handshaking_sockets.delete(ssl_socket)
    close_socket(ssl_socket)
    e
  end

  def current_clock_time
    Process.clock_gettime(Process::CLOCK_MONOTONIC)
  end

  def second_to_timeout(started_at, ends_at)
    return nil if ends_at == Float::INFINITY || ends_at.nil?

    remaining = (ends_at - started_at)
    remaining.negative? ? 0 : remaining
  end

  def expired?(started_at, ends_at)
    second_to_timeout(started_at, ends_at)&.zero?
  end

  class NetworkQueryResultChannel
    HOSTNAME_RESOLUTION_QUEUE_UPDATED = 1

    ResolutionResult = Data.define(:type, :hostname, :records, :error) do
      def success?
        error.nil?
      end

      def unexpected_error?
        case error
        when nil,
             Resolv::ResolvError,
             Resolv::ResolvTimeout,
             SocketError,
             Errno::ECONNREFUSED,
             Errno::ECONNRESET,
             Errno::ENETUNREACH,
             Errno::EHOSTUNREACH,
             Errno::ETIMEDOUT
          false
        else
          true
        end
      end
    end

    attr_reader :notifier

    def initialize
      @pending_count = 0
      @rpipe, @wpipe = IO.pipe
      @results = []
      @mutex = Mutex.new
      @notifier = [@rpipe]
    end

    # HTTPClient::NetworkQueryResultChannel#expect_result
    def expect_result
      @pending_count += 1
    end

    def pending?
      @pending_count.positive?
    end

    # HTTPClient::NetworkQueryResultChannel#add
    def add(type, hostname, records: [], error: nil)
      @mutex.synchronize do
        @results.push ResolutionResult.new(type:, hostname:, records:, error:)
        @wpipe.putc(HOSTNAME_RESOLUTION_QUEUE_UPDATED) unless @wpipe.closed?
      rescue Errno::EPIPE
        # rpipe is closed
      end
    end

    # HTTPClient::NetworkQueryResultChannel#get
    def get
      return nil if @results.empty?

      res = nil

      @mutex.synchronize do
        @rpipe.getbyte
        res = @results.shift
      end

      @pending_count -= 1
      res
    end

    def close_if_done
      return if @notifier.nil?
      close_all if @pending_count.zero?
    end

    def close_all
      @rpipe.close
      @notifier = nil
      @wpipe.close
    end
  end

  class NAT64PrefixDiscovery
    WELL_KNOWN_IPV4_ADDRESSES = [
      IPAddr.new("192.0.0.170").to_i,
      IPAddr.new("192.0.0.171").to_i,
    ].freeze
    NAT64_PREFIX_LENGTHS = [32, 40, 48, 56, 64, 96].freeze

    attr_reader :prefix

    def initialize(resolver:)
      @resolver = resolver
      @prefix = nil
    end

    # HTTPClient::NAT64PrefixDiscovery#discover!
    def discover!
      # ipv4only.arpaのAAAAレコードを問い合わせ -> 192.0.0.170あるいは192.0.0.171に合成済みのAAAAレコードを取得
      records = @resolver.getresources("ipv4only.arpa", AAAA_TYPE)
      # 取得したAAAAレコードからNAT64 prefixを取得
      @prefix = extract_prefix!(records) # => HTTPClient::NAT64PrefixDiscovery#extract_prefix!
    end

    private

    # HTTPClient::NAT64PrefixDiscovery#extract_prefix!
    def extract_prefix!(records)
      addresses = records.map { |rr| AddrInt.new(IPAddr.new_ntoh(rr.address.address).to_i) }
      prefixed_v4s = {}

      addresses.each do |addr_int|
        NAT64_PREFIX_LENGTHS.each do |prefix_len|
          next if prefix_len < 96 && !addr_int.u_octet_zero?

          v4 = addr_int.embedded_ipv4(prefix_len)
          next unless WELL_KNOWN_IPV4_ADDRESSES.include?(v4)

          label = addr_int.label(prefix_len)
          existing_v4s = prefixed_v4s[label] || []
          prefixed_v4s[label] = existing_v4s | [v4]

          return label if WELL_KNOWN_IPV4_ADDRESSES.all? { |known| prefixed_v4s[label].include?(known) }
        end
      end

      nil
    end
  end

  class NameResolutionStore
    def initialize
      @resolved_addresses = {}
      @resolved_types = Set.new
    end

    # HTTPClient::NameResolutionStore#fetch_addresses
    def fetch_addresses(hostname)
      @resolved_addresses.fetch(hostname, {})
    end

    # HTTPClient::NameResolutionStore#update
    def update(hostname, type, addresses)
      @resolved_addresses[hostname] ||= {}
      @resolved_addresses[hostname][type] = addresses
    end

    # HTTPClient::NameResolutionStore#mark_resolved
    def mark_resolved(type)
      @resolved_types << type
    end

    def resolved?(type)
      @resolved_types.include?(type)
    end
  end

  class ConnectionPlanner
    PRIORITY_ON_V6 = [AAAA_TYPE, A_TYPE]
    PRIORITY_ON_V4 = [A_TYPE, AAAA_TYPE]
    SUPPORTED_PROTOCOLS = ["h2", "http/1.1"].freeze
    DEFAULT_ALPN = ["http/1.1"].freeze
    # mandatory, alpn, no-default-alpn, port, ipv4hint, ipv6hint
    SUPPORTED_SVC_PARAM_KEYS = [0, 1, 2, 3, 4, 6].freeze
    MAX_ALIAS_REDIRECTS = 8 # RFC 9460

    # 接続設定・ヒントと候補ごとの選択状態を保持する。A/AAAAの結果は選択時に受け取る。
    class ConnectionPlan
      attr_reader :rr, :port, :ctx, :ipv6_address_hints, :ipv4_address_hints, :last_type

      def initialize(rr:, port:, ctx:, ipv6_address_hints:, ipv4_address_hints:)
        @rr = rr
        @port = port
        @ctx = ctx
        @ipv6_address_hints = ipv6_address_hints
        @ipv4_address_hints = ipv4_address_hints
        @selected_addresses = []
        @last_type = nil
      end

      def address_hints(type)
        type == AAAA_TYPE ? ipv6_address_hints : ipv4_address_hints
      end

      # HTTPClient::ConnectionPlanner::ConnectionPlan#next_address
      def next_address(type, resolved)
        # 解決済みのアドレスのうち未選択のものを取得
        address = unselected_address(type, resolved)
        # => HTTPClient::ConnectionPlanner::ConnectionPlan#unselected_address
        return unless address

        # 取得したアドレスを選択済みにする
        @selected_addresses << address.to_s
        @last_type = type
        address
      end

      def address_available?(type, resolved)
        !unselected_address(type, resolved).nil?
        # => HTTPClient::ConnectionPlanner::ConnectionPlan#unselected_address
      end

      private

      # HTTPClient::ConnectionPlanner::ConnectionPlan#unselected_address
      def unselected_address(type, resolved)
        resolved.fetch(type, address_hints(type)).find { !@selected_addresses.include?(it.to_s) }
      end
    end

    def initialize(record_types, client, origin_port:, nat64_prefix: nil)
      @record_types = record_types
      @origin_port = origin_port

      # e.g.
      # {
      #   [ホスト名, 優先度, Resolv::DNS::Resource::IN::HTTPSオブジェクト] => ConnectionPlanオブジェクト,
      #   [ホスト名, Float::INFINITY] => ConnectionPlanオブジェクト, (HTTPS RRの設定を利用しない候補の場合)
      # }
      @connection_plans = {}

      @plan_order = {}
      @name_resolution_store = NameResolutionStore.new
      @client = client
      @nat64_prefix = nat64_prefix
      @pending_ipv4_hints = {}
      @alias_redirect_count = 0
      @alias_fallback_hostname = nil
      @queried_hostnames = [HOST]
    end

    # HTTPClient::ConnectionPlanner#nat64_prefix=
    def nat64_prefix=(prefix)
      return if prefix.nil? || prefix == @nat64_prefix

      @nat64_prefix = prefix

      # @pending_ipv4_hints = 取得済みだがNAT64 prefixの検出待ちのため接続に利用できないIPv4アドレスヒント群
      # @pending_ipv4_hintsを接続候補へコピー
      @pending_ipv4_hints.each do |key, hints|
        plan = @connection_plans.fetch(key)

        # アドレス合成はnext_connection_targetで接続用アドレスを返す直前に行う
        plan.ipv4_address_hints.replace(hints)
        @name_resolution_store.mark_resolved(A_TYPE) if hints.any?
      end

      @pending_ipv4_hints.clear
    end

    # HTTPClient::ConnectionPlanner#add
    def add(result)
      if result.type == HTTPS_TYPE
        # DNS問い合わせは成功したが、HTTPS RRがなかった場合 / DNS問い合わせが失敗し、エラーが返ってきた場合
        if result.records.empty?
          handle_empty_https_rr!(result) # => HTTPClient::ConnectionPlanner#handle_empty_https_rr!
          return
        end

        # RFC 9460 Section 2.4.1: if the RRset contains any AliasMode record,
        # all ServiceMode records in the same set MUST be ignored.
        # Section 2.4.2: if multiple AliasMode records are present, pick one at random.
        # HTTPSレコードの中にAliasModeのものがある場合
        if (alias_record = result.records.select(&:alias_mode?).sample)
          resolve_alias!(alias_record) # => HTTPClient::ConnectionPlanner#resolve_alias!
          return
        end

        # 必須パラメータがあり、かつ利用可能なALPNを持つHTTPS RRを取得
        available_plans = result.records.filter_map { |rr| build_connection_plan!(rr) }
        # => HTTPClient::ConnectionPlanner#build_connection_plan!

        # 利用可能な接続候補をHTTPS RRの優先度が小さい順に並べ替える
        sorted_plans = available_plans.sort_by { |plan| plan.rr.priority }

        sorted_plans.each do |plan|
          target_name = plan.rr.target.to_s
          hostname = target_name.empty? ? result.hostname : target_name
          # AliasModeの場合、result.hostname == AliasModeの指すホスト名

          add_service_plan(hostname, plan) # => HTTPClient::ConnectionPlanner#add_service_plan
        end

        # 肯定回答かつ過去にリダイレクト履歴がある (= この結果はServiceModeとして取得)
        if result.success? && @alias_redirect_count.positive?
          # HTTPSレコードの接続設定を使わない候補も追加する
          add_alias_fallback_plan(result.hostname)
          # hostname = 今回のHTTPS問い合わせ先のホスト名
          # => HTTPClient::ConnectionPlanner#add_alias_fallback_plan
        end

      elsif result.success? # A/AAAA
        addresses = result.records.map(&:address)

        if result.type == A_TYPE
          # hostnameに対応するIPv4アドレスを取得できたので待機中のIPv4アドレスを削除
          @pending_ipv4_hints.delete_if { |(hostname, _), _hints| hostname == result.hostname }
        end

        # 名前解決できたアドレスを、問い合わせ先ホスト名ごとのレコード種別ごとに保存
        @name_resolution_store.update(result.hostname, result.type, addresses)
        # => HTTPClient::NameResolutionStore#update

        # 問い合わせ先が元のHOST、
        # あるいは今回の問い合わせ先と同じホスト名の候補がまだ一件もない場合
        # (HTTPS RRのTargetNameとして得たホスト名に対する名前解決結果の場合、このifブロックは通らない)
        if result.hostname == HOST ||
           @connection_plans.keys.none? { |(hostname, _priority)| hostname == result.hostname }

          key = [result.hostname, Float::INFINITY]
          @connection_plans[key] ||= build_connection_plan!
          # => HTTPClient::ConnectionPlanner#build_connection_plan!
        end

      end

      @name_resolution_store.mark_resolved(result.type)
      # => HTTPClient::NameResolutionStore#mark_resolved
    end

    # HTTPClient::ConnectionPlanner#next_connection_target
    def next_connection_target
      ordered_plans.each do |(hostname, _priority, _https_rr), plan|
        # => HTTPClient::ConnectionPlanner#ordered_plans

        # hostnameに対応する解決済みのA/AAAAアドレスをそれぞれ含むハッシュ取得
        resolved = @name_resolution_store.fetch_addresses(hostname)
        # => HTTPClient::NameResolutionStore#fetch_addresses

        precedences(plan.last_type).each do |type| # => HTTPClient::ConnectionPlanner#precedences
          address = plan.next_address(type, resolved)
          # => HTTPClient::ConnectionPlanner::ConnectionPlan#next_address

          next unless address

          # Aレコード・IPv4ヒント由来の候補を接続前にアドレス合成
          if type == A_TYPE && @nat64_prefix
            address = synthesize_with_nat64_prefix(address)
            # => HTTPClient::ConnectionPlanner#synthesize_with_nat64_prefix
          end

          return [plan.ctx, address, hostname, plan.port]
        end
      end

      nil
    end

    def resolved?(type)
      @name_resolution_store.resolved?(type)
    end

    # HTTPClient::ConnectionPlanner#preferred_type
    def preferred_type
      ipv6_addresses_usable? ? AAAA_TYPE : A_TYPE
    end

    # HTTPClient::ConnectionPlanner#connection_target_available?
    def connection_target_available?
      @connection_plans.any? { |key, plan|
        resolved = @name_resolution_store.fetch_addresses(key.first)
        # => HTTPClient::NameResolutionStore#fetch_addresses
        [AAAA_TYPE, A_TYPE].any? { |type| plan.address_available?(type, resolved) }
      }
    end

    private

    # HTTPClient::ConnectionPlanner#handle_empty_https_rr!
    def handle_empty_https_rr!(result)
      # DNS問い合わせが成功した、かつ元々のHTTPS RR問い合わせの結果がAliasModeだった場合
      if result.success? && @alias_redirect_count.positive?
        # 最終結果を返したときのホスト名を@alias_fallback_hostnameに設定
        # @alias_fallback_hostname = HTTPSのServiceModeレコードに基づく候補の後に接続を行う候補として扱う
        @alias_fallback_hostname = result.hostname

        # A・AAAAの問い合わせを開始済みのホスト名でなければ名前解決を開始
        resolve_target_addresses!(result.hostname) unless queried_hostname?(result.hostname)
        # => HTTPClient::ConnectionPlanner#queried_hostname?
        # => HTTPClient::ConnectionPlanner#resolve_target_addresses!
      end

      # HTTPSは解決済みということにする
      @name_resolution_store.mark_resolved(HTTPS_TYPE)
      # => HTTPClient::NameResolutionStore#mark_resolved
    end

    # HTTPClient::ConnectionPlanner#resolve_alias!
    def resolve_alias!(alias_record)
      @alias_redirect_count += 1

      # RFC 9460に従いリダイレクト回数の条件を超えているかどうかを確認
      if @alias_redirect_count <= MAX_ALIAS_REDIRECTS
        @client.resolve_hostname_asynchronously!(HTTPS_TYPE, alias_record.target.to_s)
        # => HTTPClient#resolve_hostname_asynchronously!
      else
        @name_resolution_store.mark_resolved(HTTPS_TYPE) # HTTPSは解決済みとしてA/AAAAへフォールバック
      end
    end

    # HTTPClient::ConnectionPlanner#add_service_plan
    def add_service_plan(hostname, plan)
      # hostnameが元の宛先ホストHOSTではなく、かつAliasModeのフォールバック先でもない場合
      if hostname != HOST && hostname != @alias_fallback_hostname
        # 当該ホストにはServiceModeの設定を利用して接続する必要があるので
        # 接続候補からhostnameを削除する
        @connection_plans.delete([hostname, Float::INFINITY])

        # @connection_plansに [hostname, Float::INFINITY] (ServiceModeの設定を利用しない) が登録される契機
        # 1. HTTPClient::ConnectionPlanner#addでA/AAAAの成功結果を処理する時
        #    条件: 問い合わせ先が元のHOST、または同じホスト名の候補がまだない
        #    ([A/AAAAの問い合わせ先, Float::INFINITY])
        #
        # 2. AliasModeをたどった先のServiceMode HTTPS RRの内容を接続候補として登録処理後、
        #    HTTPClient::ConnectionPlanner#add_alias_fallback_planを呼ぶ時
        #    条件: AliasModeをたどった先で、空ではないHTTPS結果を正常に取得した
        #    ([最後のHTTPS問い合わせ先, Float::INFINITY])
        #
        # ServiceMode候補の場合は [hostname, plan.rr.priority, plan.rr] というキーで登録される
      end

      # ServiceMode候補を識別するキー
      service_plan_key = [hostname, plan.rr.priority, plan.rr]

      # @pending_ipv4_hintsにservice_plan_keyが含まれていれば削除
      @pending_ipv4_hints.delete(service_plan_key)

      # hostnameに対応する解決済みのA/AAAAアドレスを取得
      resolved = @name_resolution_store.fetch_addresses(hostname)
      # => HTTPClient::NameResolutionStore#fetch_addresses

      # 対応していないアドレスファミリ (接続性のない側) のヒントはアドレスリストから除外する
      ipv6_address_hints = ipv6_addresses_usable? ? plan.ipv6_address_hints : []
      ipv4_address_hints = ipv4_addresses_usable? ? plan.ipv4_address_hints : []
      # => HTTPClient::ConnectionPlanner#ipv6_addresses_usable?
      # => HTTPClient::ConnectionPlanner#ipv4_addresses_usable?

      if resolved.key?(A_TYPE) # すでにhostnameのA RRの結果を取得済みの場合
        ipv4_address_hints = [] # アドレスヒントは利用しない (plan.ipv4_address_hints.replaceの行で使う用)
      elsif !ipv4_addresses_usable?
        # IPv4アドレスヒントを取得したものの、@record_typesにA_TYPEが含まれておらずNAT64 prefixも未検出、という状況

        # Retain unusable hints separately until a prefix is supplied.
        @pending_ipv4_hints[service_plan_key] = plan.ipv4_address_hints.dup
      end

      # @candidateに同じキーの候補があれば再利用し、なければ渡された候補を登録する
      @connection_plans[service_plan_key] ||= plan
      plan = @connection_plans[service_plan_key]

      # すでにhostnameのAAAA RRの結果を取得済みの場合、アドレスヒントは利用しない
      plan.ipv6_address_hints.replace(resolved.key?(AAAA_TYPE) ? [] : ipv6_address_hints)
      # すでにhostnameのA RRの結果を取得済みの場合、アドレスヒントは利用しない
      plan.ipv4_address_hints.replace(resolved.key?(A_TYPE) ? [] : ipv4_address_hints)

      # アドレスヒントを以てA/AAAAを解決済みとする
      # HEv3 draft Section 4.2.1: address hints in ServiceMode records SHOULD be
      # treated as positive answers until the real AAAA/A records arrive.
      @name_resolution_store.mark_resolved(AAAA_TYPE) if ipv6_address_hints.any?
      @name_resolution_store.mark_resolved(A_TYPE) if ipv4_address_hints.any?

      # hostnameのA/AAAAを未問い合わせの場合は問い合わせ開始
      resolve_target_addresses!(hostname) unless queried_hostname?(hostname)
      # => HTTPClient::ConnectionPlanner#resolve_target_addresses!
      # => HTTPClient::ConnectionPlanner#queried_hostname?
    end

    # HTTPClient::ConnectionPlanner#add_alias_fallback_plan
    def add_alias_fallback_plan(hostname)
      @alias_fallback_hostname = hostname # HTTPSレコードの接続設定を使わない接続先候補
      key = [hostname, Float::INFINITY]
      @connection_plans[key] ||= build_connection_plan!
      # => HTTPClient::ConnectionPlanner#build_connection_plan!


      resolve_target_addresses!(hostname) unless queried_hostname?(hostname)
      # => HTTPClient::ConnectionPlanner#resolve_target_addresses!
      # => HTTPClient::ConnectionPlanner#queried_hostname?
    end

    # HTTPClient::ConnectionPlanner#ipv6_addresses_usable?
    def ipv6_addresses_usable?
      @record_types.include?(AAAA_TYPE)
    end

    # HTTPClient::ConnectionPlanner#ipv4_addresses_usable?
    def ipv4_addresses_usable?
      !@nat64_prefix.nil? || @record_types.include?(A_TYPE)
    end

    # HTTPClient::ConnectionPlanner#queried_hostname?
    def queried_hostname?(hostname)
      # @queried_hostnames = A・AAAAの問い合わせを開始済みのホスト名
      @queried_hostnames.include?(hostname)
    end

    # HTTPClient::ConnectionPlanner#resolve_target_addresses!
    def resolve_target_addresses!(target_name)
      @client.resolve_hostname_asynchronously!(AAAA_TYPE, target_name) if @record_types.include?(AAAA_TYPE)
      @client.resolve_hostname_asynchronously!(A_TYPE, target_name) if @record_types.include?(A_TYPE)
      # => HTTPClient#resolve_hostname_asynchronously!

      @queried_hostnames << target_name
    end

    # HTTPClient::ConnectionPlanner##build_ssl_context
    def build_ssl_context
      ctx = ::OpenSSL::SSL::SSLContext.new
      ctx.set_params
      ctx.alpn_protocols = SUPPORTED_PROTOCOLS
      ctx
    end

    # HTTPClient::ConnectionPlanner#mandatory_params_supported?
    def mandatory_params_supported?(rr)
      mandatory = rr.params[0] # mandatoryを取得
      return true unless mandatory

      keys = mandatory.keys # 必須として指定されたパラメータ番号一覧を取得
      return false if keys.empty? # mandatoryがあるのにパラメータ番号一覧が空
      return false if keys.include?(0) # mandatory自身の番号 (0) が一覧に含まれている
      return false unless keys == keys.sort.uniq # 番号が昇順ではない、あるいは番号の重複がある

      # 必須パラメータがクライアントの対応一覧に含まれ、レコード自身が実際にそのパラメータを持っている
      keys.all? { SUPPORTED_SVC_PARAM_KEYS.include?(it) && !rr.params[it].nil? }
    end

    # HTTPClient::ConnectionPlanner#extract_alpn_protocols_from_rr
    def extract_alpn_protocols_from_rr(rr)
      alpn_param = rr.params[1]&.protocol_ids # サポートしているプロトコル一覧を取得
      no_default_alpn = rr.params[2] # no-default-alpn (= デフォルトのプロトコルを補わない) があれば取得

      # 利用できるプロトコルがない
      return [] if no_default_alpn && alpn_param.nil?
      return [] if alpn_param&.empty?

      # 接続先が対応しているプロトコル
      svcb_alpn_set =
        if alpn_param.nil? # ALPNなし
          DEFAULT_ALPN # ["http/1.1"]
        elsif no_default_alpn # ALPNあり、no-default-alpnあり
          alpn_param # ["h2"]
        else # ALPNあり、no-default-alpnなし
          (alpn_param + DEFAULT_ALPN).uniq # ["h2", "http/1.1"]
        end

      # 接続先が対応しているプロトコルとクライアントが対応しているプロトコルの積集合を取る
      svcb_alpn_set & SUPPORTED_PROTOCOLS
    end

    # HTTPClient::ConnectionPlanner#build_connection_plan!
    def build_connection_plan!(https_rr = nil)
      if https_rr
        return if !mandatory_params_supported?(https_rr) # mandatory = このレコードを扱うための必須パラメータがある
        # => HTTPClient::ConnectionPlanner#mandatory_params_supported?
        return if extract_alpn_protocols_from_rr(https_rr).empty? # 利用できるプロトコルがない
        # => HTTPClient::ConnectionPlanner#extract_alpn_protocols_from_rr
      end

      ConnectionPlan.new(
        rr: https_rr,
        port: https_rr&.params&.[](3)&.port || @origin_port,
        ctx: build_ssl_context, # => HTTPClient::ConnectionPlanner##build_ssl_context
        ipv6_address_hints: (https_rr&.params&.[](6)&.addresses || []).dup,
        ipv4_address_hints: (https_rr&.params&.[](4)&.addresses || []).dup,
      )
    end

    # HTTPClient::ConnectionPlanner#synthesize_with_nat64_prefix
    def synthesize_with_nat64_prefix(addr)
      # アドレス合成を行う
      ipv4_int = IPAddr.new_ntoh(addr.address).to_i
      AddrInt.synthesize(ipv4_int, @nat64_prefix).to_ipaddr
    end

    # HTTPClient::ConnectionPlanner#ordered_plans
    def ordered_plans
      @connection_plans.sort_by { |key, plan|
        hostname, priority = key
        group =
          if plan.rr
            0 # HTTPSのServiceModeレコードに基づく候補
          elsif hostname == @alias_fallback_hostname
            1 # AliasModeの最終問い合わせ先のA/AAAA + 元のポートを利用する候補
          else
            2 # 元のHOSTのA/AAAA + 元のポートを使う候補など
          end

        @plan_order[key] ||= rand
        # その候補のキーに乱数が未登録なら生成して保存
        # グループも優先度も同じ候補の場合はrandの値が小さい方が優先的に接続対象となる

        # 1. group の昇順
        # 2. group が同じなら、priority の昇順
        # 3. 両方同じなら、乱数の昇順
        [group, priority, @plan_order[key]]
      }
    end

    # HTTPClient::ConnectionPlanner#precedences
    def precedences(last_type)
      if last_type == AAAA_TYPE then PRIORITY_ON_V4
      elsif last_type == A_TYPE then PRIORITY_ON_V6
      elsif preferred_type == AAAA_TYPE then PRIORITY_ON_V6 # => HTTPClient::ConnectionPlanner#preferred_type
      else PRIORITY_ON_V4
      end
    end

  end

  class AddrInt
    def self.synthesize(ipv4_int, nat64_prefix_str)
      prefix_addr, prefix_len_str = nat64_prefix_str.split("/")
      prefix_len = prefix_len_str.to_i
      prefix_int = IPAddr.new(prefix_addr).to_i

      ipv6_int = case prefix_len
      when 96 then prefix_int | ipv4_int
      when 64 then prefix_int | (ipv4_int << 24)
      when 56 then prefix_int | (((ipv4_int >> 24) & 0xff) << 64) | ((ipv4_int & 0xffffff) << 32)
      when 48 then prefix_int | (((ipv4_int >> 16) & 0xffff) << 64) | ((ipv4_int & 0xffff) << 40)
      when 40 then prefix_int | (((ipv4_int >> 8) & 0xffffff) << 64) | ((ipv4_int & 0xff) << 48)
      when 32 then prefix_int | (ipv4_int << 64)
      end

      new(ipv6_int)
    end

    def initialize(int)
      @int = int
    end

    def to_ipaddr
      IPAddr.new(@int, Socket::AF_INET6)
    end

    def u_octet_zero?
      ((@int >> 56) & 0xff).zero?
    end

    def embedded_ipv4(prefix_len)
      case prefix_len
      when 96 then @int & 0xffffffff
      when 64 then (@int >> 24) & 0xffffffff
      when 56 then (((@int >> 64) & 0xff) << 24) | ((@int >> 32) & 0xffffff)
      when 48 then (((@int >> 64) & 0xffff) << 16) | ((@int >> 40) & 0xffff)
      when 40 then (((@int >> 64) & 0xffffff) << 8) | ((@int >> 48) & 0xff)
      when 32 then (@int >> 64) & 0xffffffff
      end
    end

    def label(prefix_len)
      "#{IPAddr.new(nat64_prefix(prefix_len), Socket::AF_INET6)}/#{prefix_len}"
    end

    private

    def nat64_prefix(prefix_len)
      shift = 128 - prefix_len
      (@int >> shift) << shift
    end
  end

  private_constant :AddrInt
end

HTTPClient.run
