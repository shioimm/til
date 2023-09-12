require 'socket'

class Socket
  RESOLUTION_DELAY = 0.05
  private_constant :RESOLUTION_DELAY

  CONNECTION_ATTEMPT_DELAY = 0.25
  private_constant :CONNECTION_ATTEMPT_DELAY

  class ConnectionAttempt
    attr_reader :connected_sockets, :connecting_sockets, :last_error

    def initialize(local_addrinfos = [])
      @local_addrinfos = local_addrinfos
      @connected_sockets = []
      @connecting_sockets = []
    end

    def attempt(addrinfo, delay_timers)
      return if !@connected_sockets.empty?

      socket = Socket.new(addrinfo.pfamily, addrinfo.socktype, addrinfo.protocol)

      if !@local_addrinfos.empty?
        local_addrinfo = @local_addrinfos.find { |local_ai| local_ai.afamily == addrinfo.afamily }
        socket.bind(local_addrinfo) if local_addrinfo
      end

      now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      delay_timers.push now + CONNECTION_ATTEMPT_DELAY

      begin
        case socket.connect_nonblock(addrinfo, exception: false)
        when 0              then @connected_sockets.push socket
        when :wait_writable then @connecting_sockets.push socket
        end
      rescue SystemCallError => e
        @last_error = e
        socket.close unless socket.closed?
      end
    end

    def take_connected_socket(addrinfo)
      @connected_sockets.find do |socket|
        begin
          socket.connect_nonblock(addrinfo)
          true
        rescue Errno::EISCONN # already connected
          true
        rescue => e
          @last_error = e
          socket.close unless socket.closed?
          false
        ensure
          @connected_sockets.delete socket
          @connecting_sockets.delete socket
        end
      end
    end

    def close_all_sockets!
      @connecting_sockets.each(&:close)
      @connected_sockets.each(&:close)
    end
  end

  private_constant :ConnectionAttempt

  def self.tcp(host, port, local_host = nil, local_port = nil, resolv_timeout: nil, connect_timeout: nil)
    mutex = Mutex.new
    cond = ConditionVariable.new

    # アドレス解決 (Producer)
    local_addrinfos = []
    pickable_addrinfos = []
    resolution_state = { ipv6_done: false, ipv4_done: false, error: [] }

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

    hostname_resolution_threads = hostname_resolving_families.map do |family|
      Thread.new { hostname_resolution(host, port, family, pickable_addrinfos, mutex, cond, resolution_state) }
    end

    # 接続試行 (Consumer)
    started_at = current_clocktime
    connection_attempt = ConnectionAttempt.new(local_addrinfos)
    last_attemped_addrinfo = nil
    connection_attempt_delay_timers = []
    connection_established = false

    ret = loop do
      if connection_established
        connected_socket = connection_attempt.take_connected_socket(last_attemped_addrinfo)

        if connected_socket.nil? && connection_attempt.last_error
          raise connection_attempt.last_error if pickable_addrinfos.empty?

          connection_established = false
          next
        end

        connection_attempt.close_all_sockets!
        break connected_socket
      end

      addrinfo =
        if resolution_state[:ipv6_done] && resolution_state[:ipv4_done] && pickable_addrinfos.empty?
          nil
        else
          pick_addrinfo(pickable_addrinfos, last_attemped_addrinfo&.afamily, resolv_timeout, mutex, cond)
        end

      if !addrinfo && !connection_attempt.connecting_sockets.empty?
        # アドレス在庫が枯渇しており、接続中のソケットがある場合
        to_timeout = second_to_timeout(started_at, connect_timeout)
        _, selected_sockets, = IO.select(nil, connection_attempt.connecting_sockets, nil, to_timeout)

        if selected_sockets && !selected_sockets.empty?
          # connect_timeout終了前に接続できたソケットがある場合
          connection_attempt.connected_sockets.push *selected_sockets
          connection_established = true
          next
        elsif selected_sockets.nil?
          # connect_timeoutまでに名前解決できなかった場合
          raise Errno::ETIMEDOUT, 'user specified timeout'
        end
      elsif !addrinfo && connection_attempt.last_error
        # アドレス在庫が枯渇しており、全てのソケットの接続に失敗している場合
        raise connection_attempt.last_error
      elsif !addrinfo
        # pick_addrinfoがnilを返した場合 (Resolve Timeout)
        raise Errno::ETIMEDOUT, 'user specified timeout'
      elsif resolution_state[:ipv6_done] && resolution_state[:ipv4_done] &&
            !pickable_addrinfos.empty? &&
            !(errors = resolution_state[:error]).empty?
        # 名前解決中にエラーが発生した場合
        error = errors.shift until errors.empty?
        raise error[:klass], error[:message]
      end

      last_attemped_addrinfo = addrinfo
      connection_attempt.attempt(addrinfo, connection_attempt_delay_timers)

      if !connection_attempt.connected_sockets.empty?
        connection_established = true
        next
      end

      if (connection_attempt.last_error && !pickable_addrinfos.empty?) || # 別アドレスで再試行
         (pickable_addrinfos.empty? && connection_attempt.connecting_sockets.empty?) # 別アドレスの取得を待機
        next
      end

      timer = connection_attempt_delay_timers.shift
      connection_attempt_delay = (delay_time = timer - current_clocktime).negative? ? 0 : delay_time
      _, selected_sockets, = IO.select(nil, connection_attempt.connecting_sockets, nil, connection_attempt_delay)

      if selected_sockets && !selected_sockets.empty?
        connection_attempt.connected_sockets.push *selected_sockets
        connection_established = true
        next
      end
    end

    if block_given?
      begin
        yield ret
      ensure
        hostname_resolution_threads.each {|th| th&.exit }
        ret.close
      end
    else
      ret
    end
  ensure
    hostname_resolution_threads.each {|th| th&.exit }
  end

  def self.hostname_resolution(hostname, port, family, pickable_addrinfos, mutex, cond, resolution_state)
    resolved_addrinfos = Addrinfo.getaddrinfo(hostname, port, family, :STREAM)

    if family == :PF_INET && !pickable_addrinfos.any?(&:ipv6?)
      sleep RESOLUTION_DELAY
    end

    mutex.synchronize do
      pickable_addrinfos.push *resolved_addrinfos
      cond.signal
    end
  rescue => e
    ignoring_error_messages = [
      "getaddrinfo: Address family for hostname not supported",
      "getaddrinfo: Temporary failure in name resolution",
    ]
    if e.class.is_a?(SocketError) && ignoring_error_messages.include?(e.message)
      # ignore
    else
      mutex.synchronize do
        resolution_state[:error].push({ klass: e.class, message: e.message })
      end
    end
  ensure
    family_name = family == :PF_INET6 ? :ipv6_done : :ipv4_done
    mutex.synchronize do
      resolution_state[family_name] = true
    end
  end

  private_class_method :hostname_resolution

  def self.pick_addrinfo(pickable_addrinfos, last_family, resolv_timeout, mutex, cond)
    mutex.synchronize do
      cond.wait(mutex, resolv_timeout) if pickable_addrinfos.empty?

      if last_family && (addrinfo = pickable_addrinfos.find { |addrinfo| !addrinfo.afamily == last_family })
        pickable_addrinfos.delete addrinfo
      else
        pickable_addrinfos.shift
      end
    end
  end

  private_class_method :pick_addrinfo

  def self.current_clocktime
    Process.clock_gettime(Process::CLOCK_MONOTONIC)
  end

  private_class_method :current_clocktime

  def self.second_to_timeout(started_at, waiting_time)
    return if waiting_time.nil?

    elapsed_time = current_clocktime - started_at
    timeout = waiting_time - elapsed_time
    timeout.negative? ? 0 : timeout
  end

  private_class_method :second_to_timeout
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
# 名前解決動作確認用 (例外)
Addrinfo.define_singleton_method(:getaddrinfo) do |_, _, family, *_|
  if family == :PF_INET6
    [Addrinfo.tcp("::1", PORT)]
  else
    raise SocketError
  end
end
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
