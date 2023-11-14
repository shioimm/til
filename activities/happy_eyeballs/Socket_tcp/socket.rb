# イベントループをベースにする

require 'socket'

class Socket
  RESOLUTION_DELAY = 0.05
  private_constant :RESOLUTION_DELAY

  CONNECTION_ATTEMPT_DELAY = 0.25
  private_constant :CONNECTION_ATTEMPT_DELAY

  ADDRESS_FAMILIES = {
    ipv6: Socket::AF_INET6,
    ipv4: Socket::AF_INET
  }.freeze
  private_constant :ADDRESS_FAMILIES

  def self.tcp(host, port, local_host = nil, local_port = nil, resolv_timeout: nil, connect_timeout: nil)
    # Happy Eyeballs' states
    # - :start
    # - :v6c
    # - :v4w
    # - :v4c
    # - :v46c
    # - :v46w
    # - :success
    # - :failure
    # - :timeout

    # WIP
    state = :start

    addrinfos = []
    connected_sockets = []
    connecting_sockets = []
    next_family = nil

    mutex = Mutex.new
    read_resolved_family, write_resolved_family = IO.pipe
    hostname_resolution_threads = []

    started_at = current_clocktime
    connection_attempt_delay_timers = []
    last_error = nil

    connected_socket = loop do
      case state
      when :start
        hostname_resolution_threads.concat(ADDRESS_FAMILIES.keys.map do |family|
          Thread.new(host, port, family) do |host, port, family|
            resolved_addrinfos = Addrinfo.getaddrinfo(host, port, ADDRESS_FAMILIES[family], :STREAM)

            mutex.synchronize do
              addrinfos.concat resolved_addrinfos
              write_resolved_family.putc ADDRESS_FAMILIES[family]
            end
          end
        end)

        resolved_families, _, = IO.select([read_resolved_family], nil, nil, resolv_timeout)

        unless resolved_families
          state = :timeout # "user specified timeout"
          next
        end

        case read_resolved_family.getbyte
        when ADDRESS_FAMILIES[:ipv6] then state = :v6c
        when ADDRESS_FAMILIES[:ipv4] then state = :v4w
        end

        next
      when :v4w
        resolved_ipv6, _, = IO.select([read_resolved_family], nil, nil, RESOLUTION_DELAY)
        state = resolved_ipv6 ? :v46c : :v4c
        next
      when :v4c, :v6c, :v46c
        family =
          case state
          when :v46c
            next_family ? next_family : ADDRESS_FAMILIES[:ipv6]
          when :v6c, :v4c
            family_name = "ipv#{state.to_s[1]}"
            ADDRESS_FAMILIES[family_name.to_sym]
          end

        addrinfo = addrinfos.find { |addrinfo| addrinfo.afamily == family }

        mutex.synchronize do
          addrinfos.delete addrinfo
        end

        socket = Socket.new(addrinfo.pfamily, addrinfo.socktype, addrinfo.protocol)
        connection_attempt_delay_timers.push current_clocktime + CONNECTION_ATTEMPT_DELAY

        begin
          case socket.connect_nonblock(addrinfo, exception: false)
          when 0
            connected_socket = socket
            state = :success
          when :wait_writable
            connecting_sockets.push socket
            state = :v46w
          end
        rescue SystemCallError => e
          last_error = e
          socket.close unless socket.closed?
          state = :failure
        end

        current_family_name = ADDRESS_FAMILIES.key(addrinfo.afamily)
        next_family = ADDRESS_FAMILIES.fetch(ADDRESS_FAMILIES.keys.find { |k| k != current_family_name })

        next
      when :v46w
        if connect_timeout && second_to_connection_timeout(started_at + connect_timeout).zero?
          state = :timeout # "user specified timeout"
          next
        end

        connection_attempt_ends_at = connection_attempt_delay_timers.shift
        timeout = second_to_connection_timeout(connection_attempt_ends_at)

        resolved_families, connected_sockets, = IO.select([read_resolved_family], connecting_sockets, nil, timeout)

        if !resolved_families.empty?
          connection_attempt_delay_timers.unshift connection_attempt_ends_at
          read_resolved_family.getbyte
          state = :v46c
        elsif !connected_sockets.empty?
          connected_socket = connected_sockets.pop
          state = :success
        elsif resolved_families.nil? && connected_sockets.nil?
          addrinfos.empty? ? (state = :v46w) : (state = :v46c)
        end

        next
      when :success
        break connected_socket
      when :failure
        raise last_error
      when :timeout
        raise Errno::ETIMEDOUT, 'user specified timeout'
      end
    end

    if block_given?
      begin
        yield connected_socket
      ensure
        hostname_resolution_threads.each { |th| th&.exit }
        connected_socket.close
      end
    else
      connected_socket
    end
  ensure
    hostname_resolution_threads.each { |th| th&.exit }
  end

  def self.second_to_connection_timeout(ends_at)
    return 0 unless ends_at

    remaining = (ends_at - current_clocktime)
    remaining.negative? ? 0 : remaining
  end
  private_class_method :second_to_connection_timeout

  def self.current_clocktime
    Process.clock_gettime(Process::CLOCK_MONOTONIC)
  end
  private_class_method :current_clocktime
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
# # 名前解決動作確認用 (例外)
# Addrinfo.define_singleton_method(:getaddrinfo) do |_, _, family, *_|
#   if family == :PF_INET6
#     [Addrinfo.tcp("::1", PORT)]
#   else
#     # NOTE ignoreされる
#     raise SocketError, 'getaddrinfo: Address family for hostname not supported'
#   end
# end
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
