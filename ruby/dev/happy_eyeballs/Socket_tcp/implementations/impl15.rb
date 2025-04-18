require 'socket'

class Socket
  RESOLUTION_DELAY = 0.05
  private_constant :RESOLUTION_DELAY

  CONNECTION_ATTEMPT_DELAY = 0.25
  private_constant :CONNECTION_ATTEMPT_DELAY

  def self.tcp(host, port, local_host = nil, local_port = nil, resolv_timeout: nil, connect_timeout: nil)
    # アドレス解決 (Producer)
    controller = Ractor.new do
      pickable_ip_addresses = []
      response = {
        ip_address: nil,
        is_ip6_resolved: false,
        is_ip4_resolved: false,
        error: nil,
      }

      loop do
        client, request, arg = Ractor.receive

        case request
        when :add_addrinfos
          storage_name = arg.first.match?(/:/) ? :is_ip6_resolved : :is_ip4_resolved
          response[storage_name] = true
          pickable_ip_addresses.push *arg
          true
        when :pick_addrinfo
          if response[:is_ip6_resolved] && response[:is_ip4_resolved]
            response[:ip_address] = nil
          elsif (last_pattern = arg[:last_addrinfo]&.match?(/:/) ? /:/ : /\./) &&
            (ip_address = pickable_ip_addresses.find { |address| !address.match?(last_pattern) })
            pickable_ip_addresses.delete ip_address
            response[:ip_address] = ip_address
          else
            ip_address = pickable_ip_addresses.shift
            response[:ip_address] = ip_address
          end
        when :current_status
          # Return current status
        when :save_error
          storage_name = arg[:family] == :PF_INET6 ? :is_ip6_resolved : :is_ip4_resolved
          response[storage_name] = true
          response[:error] = arg.slice(:klass, :message)
        else
          nil
        end

        client.send response
      end
    end

    local_addrinfos = []
    pickable_addrinfos = []

    if local_host && local_port
      hostname_resolving_families = []
      local_addrinfos = Addrinfo.getaddrinfo(local_host, local_port, nil, :STREAM, nil)

      [Socket::AF_INET6, Socket::AF_INET].each do |family|
        if local_addrinfos.any? { |local_ai| local_ai.pfamily === family }
          hostname_resolving_families.push (family == Socket::AF_INET6 ? :PF_INET6 : :PF_INET)
        end
      end
    else
      hostname_resolving_families = [:PF_INET6, :PF_INET]
    end

    hostname_resolving_families.each do |family|
      getaddrinfo_args = [controller, host, port, family, resolv_timeout]

      Ractor.new(*getaddrinfo_args) do |controller, host, port, family, resolv_timeout|
        addrinfos = Addrinfo.getaddrinfo(host, port, family, :STREAM, timeout: resolv_timeout)
        ip_addresses = addrinfos.map(&:ip_address)

        # Resolution Delay
        if family == :PF_INET
          controller.send [Ractor.current, :current_status]
          response = Ractor.receive
          sleep RESOLUTION_DELAY unless response[:is_ip6_resolved]
        end

        controller.send [Ractor.current, :add_addrinfos, ip_addresses]
        Ractor.receive # キューのフラッシュ
      rescue => e
        ignoring_error_messages = [
          "getaddrinfo: Address family for hostname not supported",
          "getaddrinfo: Temporary failure in name resolution",
        ]
        if e.is_a?(SocketError) && ignoring_error_messages.include?(e.message)
          # ignore
        else
          controller.send [Ractor.main, :save_error, { family: family, klass: e.class, message: e.message }]
        end
      end
    end

    # 接続試行 (Consumer)
    started_at = current_clocktime
    last_attempted_addrinfo = nil
    connection_attempt_delay_timers = []
    connection_established = false

    connected_sockets = []
    connecting_sockets = []
    last_connection_error = nil

    ret = loop do
      if connection_established
        connected_socket, last_connection_error =
          take_connected_socket(last_attempted_addrinfo, connected_sockets, connecting_sockets)

        if connected_socket.nil? && last_connection_error
          raise last_connection_error if pickable_addrinfos.empty?

          connection_established = false
          next
        end

        connecting_sockets.each(&:close)
        connected_sockets.each(&:close)
        break connected_socket
      end

      controller.send [Ractor.current, :pick_addrinfo, { last_addrinfo: last_attempted_addrinfo&.ip_address }]
      response = Ractor.receive
      ip_address = response[:ip_address]

      if !ip_address && !connecting_sockets.empty?
        # アドレス在庫が枯渇しており、接続中のソケットがある場合
        connection_timeout = second_to_connection_timeout(started_at, connect_timeout)
        _, selected_sockets, = IO.select(nil, connecting_sockets, nil, connection_timeout)

        if selected_sockets && !selected_sockets.empty?
          # connect_timeout終了前に接続できたソケットがある場合
          connected_sockets.push *selected_sockets
          connection_established = true
          next
        elsif selected_sockets.nil?
          # connect_timeoutまでに名前解決できなかった場合
          raise Errno::ETIMEDOUT, 'user specified timeout'
        end
      elsif !ip_address && last_connection_error
        # アドレス在庫が枯渇しており、全てのソケットの接続に失敗している場合
        raise last_connection_error
      elsif !ip_address && (error = response[:error])
        # 名前解決中にエラーが発生した場合
        # まだアドレス解決中のファミリがある場合は次のループへスキップ
        if response[:is_ip6_resolved] && response[:is_ip4_resolved]
          raise error[:klass], error[:message]
        else
          next
        end
      elsif !ip_address && (!response[:is_ip6_resolved] || !response[:is_ip4_resolved])
        next
      elsif !ip_address
        # controllerがnilを返した場合 (Resolve Timeout)
        raise Errno::ETIMEDOUT, 'user specified timeout'
      end

      family = ip_address.match?(/:/) ? :PF_INET6 : :PF_INET
      sockaddr_in = Socket.sockaddr_in(port, ip_address)
      addrinfo = Addrinfo.new(sockaddr_in, family, :STREAM, 0)
      last_attempted_addrinfo = addrinfo

      connected_sockets, connecting_sockets, last_connection_error =
        connection_attempt!(addrinfo, connection_attempt_delay_timers, local_addrinfos)

      if !connected_sockets.empty?
        connection_established = true
        next
      end

      if (last_connection_error && !pickable_addrinfos.empty?) || # 別アドレスで再試行
         (pickable_addrinfos.empty? && connecting_sockets.empty?) # 別アドレスの取得を待機
        next
      end

      timer = connection_attempt_delay_timers.shift
      connection_attempt_delay = (delay_time = timer - current_clocktime).negative? ? 0 : delay_time
      _, selected_sockets, = IO.select(nil, connecting_sockets, nil, connection_attempt_delay)

      if selected_sockets && !selected_sockets.empty?
        connected_sockets.push *selected_sockets
        connection_established = true
        next
      end
    end

    if block_given?
      begin
        yield ret
      ensure
        ret.close
      end
    else
      ret
    end
  end

  def self.connection_attempt!(addrinfo, delay_timers, local_addrinfos = [])
    # どういう状況でconnected_sockets.empty?が偽になりうるのかがわからない
    # return if !connected_sockets.empty?

    connected_sockets = []
    connecting_sockets = []
    last_error = nil

    socket = Socket.new(addrinfo.pfamily, addrinfo.socktype, addrinfo.protocol)

    if !local_addrinfos.empty?
      local_addrinfo = local_addrinfos.find { |local_ai| local_ai.afamily == addrinfo.afamily }
      socket.bind(local_addrinfo) if local_addrinfo
    end

    now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    delay_timers.push now + CONNECTION_ATTEMPT_DELAY

    begin
      case socket.connect_nonblock(addrinfo, exception: false)
      when 0              then connected_sockets.push socket
      when :wait_writable then connecting_sockets.push socket
      end
    rescue SystemCallError => e
      last_error = e
      socket.close unless socket.closed?
    end

    [connected_sockets, connecting_sockets, last_error]
  end

  private_class_method :connection_attempt!

  def self.current_clocktime
    Process.clock_gettime(Process::CLOCK_MONOTONIC)
  end

  private_class_method :current_clocktime

  def self.second_to_connection_timeout(started_at, waiting_time)
    return if waiting_time.nil?

    elapsed_time = current_clocktime - started_at
    timeout = waiting_time - elapsed_time
    timeout.negative? ? 0 : timeout
  end

  private_class_method :second_to_connection_timeout

  def self.take_connected_socket(addrinfo, connected_sockets, connecting_sockets)
    last_error = nil

    connected_socket = connected_sockets.find do |socket|
      begin
        socket.connect_nonblock(addrinfo)
        true
      rescue Errno::EISCONN # already connected
        true
      rescue => e
        last_error = e
        socket.close unless socket.closed?
        false
      ensure
        connected_sockets.delete socket
        connecting_sockets.delete socket
      end
    end

    [connected_socket, last_error]
  end

  private_class_method :take_connected_socket
end

# HOSTNAME = "www.google.com"
# PORT = 80
HOSTNAME = "localhost"
PORT = 9292
#
# # # 名前解決動作確認用 (遅延)
# # Addrinfo.define_singleton_method(:getaddrinfo) do |_, _, family, *_|
# #   if family == :PF_INET6
# #     sleep 0.025
# #     [Addrinfo.tcp("::1", PORT)]
# #   else
# #     [Addrinfo.tcp("127.0.0.1", PORT)]
# #   end
# # end
#
# # # 名前解決動作確認用 (タイムアウト)
# # Addrinfo.define_singleton_method(:getaddrinfo) { |*_| sleep }
#
# # # 名前解決動作確認用 (例外)
# # Addrinfo.define_singleton_method(:getaddrinfo) do |_, _, family, *_|
# #   if family == :PF_INET6
# #     [Addrinfo.tcp("::1", PORT)]
# #   else
# #     # NOTE ignoreされる
# #     raise SocketError, 'getaddrinfo: Address family for hostname not supported'
# #   end
# # end
#
# # # local_host / local_port を指定する場合
# # Socket.tcp(HOSTNAME, PORT, 'localhost', (32768..61000).to_a.sample) do |socket|
# #   p socket.addr
# #   socket.write "GET / HTTP/1.0\r\n\r\n"
# #   print socket.read
# #   socket.close
# # end
#
Socket.tcp(HOSTNAME, PORT) do |socket|
  socket.write "GET / HTTP/1.0\r\n\r\n"
  print socket.read
  socket.close
end
