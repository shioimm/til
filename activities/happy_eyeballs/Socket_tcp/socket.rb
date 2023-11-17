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

    state = :start

    selectable_addrinfos = []
    connecting_sockets = []
    sock_ai_pairs = {}
    next_family = nil

    mutex = Mutex.new
    hostname_resolution_read_pipe, hostname_resolution_write_pipe = IO.pipe
    hostname_resolution_threads = []
    hostname_resolution_errors = []

    started_at = current_clocktime
    connection_attempt_delay_ends_ats = []
    last_error = nil

    hostname_resolution_family_names, local_addrinfos =
      if local_host && local_port
        local_addrinfos = Addrinfo.getaddrinfo(local_host, local_port, nil, :STREAM, nil)
        hostname_resolution_family_names = local_addrinfos.map { |lai| ADDRESS_FAMILIES.key(lai.afamily) }

        [hostname_resolution_family_names, local_addrinfos]
      else
        [ADDRESS_FAMILIES.keys, []]
      end

    connected_socket = loop do
      case state
      when :start
        hostname_resolution_threads.concat(hostname_resolution_family_names.map do |family|
          Thread.new(host, port, family) do |host, port, family|
            begin
              addrinfos = Addrinfo.getaddrinfo(host, port, ADDRESS_FAMILIES[family], :STREAM)

              mutex.synchronize do
                selectable_addrinfos.concat addrinfos
                hostname_resolution_write_pipe.putc ADDRESS_FAMILIES[family]
              end
            rescue => e
              if e.is_a? SocketError
                case e.message
                when 'getaddrinfo: Address family for hostname not supported' # FIXME when IPv6 is not supported
                  # ignore
                when 'getaddrinfo: Temporary failure in name resolution' # FIXME when timed out (EAI_AGAIN)
                  # ignore
                end
              else
                mutex.synchronize do
                  hostname_resolution_errors.push e
                  hostname_resolution_write_pipe.putc 0
                end
              end
            end
          end
        end)

        hostname_resolved, _, = IO.select([hostname_resolution_read_pipe], nil, nil, resolv_timeout)

        unless hostname_resolved # resolv_timeoutでタイムアウトした場合
          state = :timeout # "user specified timeout"
          next
        end

        case hostname_resolution_read_pipe.getbyte
        when ADDRESS_FAMILIES[:ipv6] then state = :v6c
        when ADDRESS_FAMILIES[:ipv4] then state = :v4w
        else
          remaining_second = resolv_timeout ? second_to_connection_timeout(started_at + resolv_timeout) : nil
          hostname_resolved, _, = IO.select([hostname_resolution_read_pipe], nil, nil, remaining_second)

          unless hostname_resolved # resolv_timeoutでタイムアウトした場合
            state = :timeout # "user specified timeout"
            next
          end

          case hostname_resolution_read_pipe.getbyte
          when ADDRESS_FAMILIES[:ipv6] then state = :v6c
          when ADDRESS_FAMILIES[:ipv4] then state = :v4w
          else
            last_error = hostname_resolution_errors.pop
            state = :failure
          end
        end

        next
      when :v4w
        ipv6_resolved, _, = IO.select([hostname_resolution_read_pipe], nil, nil, RESOLUTION_DELAY)
        state = ipv6_resolved ? :v46c : :v4c
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

        addrinfo = selectable_addrinfos.find { |ai| ai.afamily == family }

        mutex.synchronize do
          selectable_addrinfos.delete addrinfo
        end

        socket = Socket.new(addrinfo.pfamily, addrinfo.socktype, addrinfo.protocol)

        if !local_addrinfos.empty?
          local_addrinfo = local_addrinfos.find { |lai| lai.afamily == addrinfo.afamily }
          socket.bind(local_addrinfo) if local_addrinfo
        end

        connection_attempt_delay_ends_ats.push current_clocktime + CONNECTION_ATTEMPT_DELAY

        begin
          case socket.connect_nonblock(addrinfo, exception: false)
          when 0
            connected_socket = socket
            state = :success
          when :wait_writable
            connecting_sockets.push socket
            sock_ai_pairs[socket] = addrinfo
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

        connection_attempt_ends_at = connection_attempt_delay_ends_ats.shift
        remaining_second = second_to_connection_timeout(connection_attempt_ends_at)

        _hostname_resolved, connectable_sockets, = IO.select([hostname_resolution_read_pipe], connecting_sockets, nil, remaining_second)

        if connectable_sockets && !connectable_sockets.empty?
          while (connectable_socket = connectable_sockets.pop)
            begin
              target_socket = connecting_sockets.delete(connectable_socket)
              target_socket.connect_nonblock(sock_ai_pairs[target_socket])
            rescue Errno::EISCONN # already connected
              connected_socket = target_socket
              state = :success
            rescue => e
              last_error = e
              target_socket.close unless target_socket.closed?

              if selectable_addrinfos.empty? && connecting_sockets.empty?
                state = :failure
              else
                connection_attempt_delay_ends_ats.unshift connection_attempt_ends_at
                state = selectable_addrinfos.empty? ? :v46w : :v46c
              end
            ensure
              sock_ai_pairs.reject! { |s, _| s == target_socket }
            end
          end
        elsif !selectable_addrinfos.empty? # アドレス解決に成功
          connection_attempt_delay_ends_ats.unshift connection_attempt_ends_at
          hostname_resolution_read_pipe.getbyte
          state = :v46c
        else
          state = :v46w
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
        connected_socket.close
      end
    else
      connected_socket
    end
  ensure
    hostname_resolution_threads.each do |th|
      th&.exit
    end

    [hostname_resolution_read_pipe,
     hostname_resolution_write_pipe,
     connecting_sockets].each do |io|
      begin
        io.close if io && !io.closed?
      rescue
        # ignore error
      end
    end
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
# # local_host / local_port を指定する場合
# Socket.tcp(HOSTNAME, PORT, 'localhost', (32768..61000).to_a.sample) do |socket|
#   socket.write "GET / HTTP/1.0\r\n\r\n"
#   print socket.read
# end
#
Socket.tcp(HOSTNAME, PORT) do |socket|
  socket.write "GET / HTTP/1.0\r\n\r\n"
  print socket.read
end
