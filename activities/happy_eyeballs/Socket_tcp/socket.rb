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
    last_error = nil

    mutex = Mutex.new
    hostname_resolution_read_pipe, hostname_resolution_write_pipe = IO.pipe
    hostname_resolution_threads = []
    hostname_resolution_errors = []
    hostname_resolution_started_at = nil
    selectable_addrinfos = []

    connecting_sockets = []
    connection_attempt_delay_timers = []
    connection_attempt_started_at = nil
    sock_ai_pairs = {}
    last_connecting_family = nil
    v46w_read_pipe = [hostname_resolution_read_pipe]

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
        hostname_resolution_started_at = current_clocktime
        hostname_resolution_args =
          [host, port, selectable_addrinfos, mutex, hostname_resolution_write_pipe, hostname_resolution_errors]

        hostname_resolution_threads.concat(
          hostname_resolution_family_names.map { |family|
            thread_args = [family].concat hostname_resolution_args
            Thread.new(*thread_args) { |*thread_args| hostname_resolution(*thread_args) }
          }
        )

        state, last_error = after_hostname_resolution_state(
          hostname_resolution_read_pipe,
          hostname_resolution_started_at,
          resolv_timeout,
          mutex,
          hostname_resolution_errors,
        )

        next
      when :v4w
        ipv6_resolved, _, = IO.select([hostname_resolution_read_pipe], nil, nil, RESOLUTION_DELAY)
        state = ipv6_resolved ? :v46c : :v4c
        next
      when :v4c, :v6c, :v46c
        connection_attempt_started_at = current_clocktime unless connection_attempt_started_at
        family = select_connecting_family(state, last_connecting_family)
        addrinfo = selectable_addrinfos.find { |ai| ai.afamily == family }

        mutex.synchronize do
          selectable_addrinfos.delete addrinfo
        end

        socket = Socket.new(addrinfo.pfamily, addrinfo.socktype, addrinfo.protocol)

        if !local_addrinfos.empty?
          local_addrinfo = local_addrinfos.find { |lai| lai.afamily == addrinfo.afamily }
          socket.bind(local_addrinfo) if local_addrinfo
        end

        connection_attempt_delay_timers.push current_clocktime + CONNECTION_ATTEMPT_DELAY

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

        last_connecting_family = addrinfo.afamily
        next
      when :v46w
        if connect_timeout && second_to_connection_timeout(connection_attempt_started_at + connect_timeout).zero?
          state = :timeout # "user specified timeout"
          next
        end

        connection_attempt_timer_expires_at = connection_attempt_delay_timers.shift
        remaining_second = second_to_connection_timeout(connection_attempt_timer_expires_at)

        hostname_resolved, connectable_sockets, = IO.select(v46w_read_pipe, connecting_sockets, nil, remaining_second)

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
                connection_attempt_delay_timers.unshift connection_attempt_timer_expires_at
                state = selectable_addrinfos.empty? ? :v46w : :v46c
              end
            ensure
              sock_ai_pairs.reject! { |s, _| s == target_socket }
            end
          end
        elsif !selectable_addrinfos.empty?
          connection_attempt_delay_timers.unshift connection_attempt_timer_expires_at

          if hostname_resolved
            hostname_resolution_read_pipe.getbyte
            hostname_resolution_read_pipe.close if !hostname_resolution_read_pipe.closed?
            hostname_resolution_write_pipe.close if !hostname_resolution_write_pipe.closed?
            v46w_read_pipe = nil
          end

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

  def self.hostname_resolution(family, host, port, addrinfos, mutex, wpipe, errors)
    begin
      resolved_addrinfos = Addrinfo.getaddrinfo(host, port, ADDRESS_FAMILIES[family], :STREAM)

      mutex.synchronize do
        addrinfos.concat resolved_addrinfos
        wpipe.putc ADDRESS_FAMILIES[family]
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
          errors.push e
          wpipe.putc 0
        end
      end
    end
  end
  private_class_method :hostname_resolution

  def self.after_hostname_resolution_state(rpipe, started_at, timeout, mutex, errors, is_retrying: false)
    remaining_second = timeout ? second_to_connection_timeout(started_at + timeout) : nil
    hostname_resolved, _, = IO.select([rpipe], nil, nil, remaining_second)

    unless hostname_resolved # resolv_timeoutでタイムアウトした場合
      return [:timeout, nil] # "user specified timeout"
    end

    case rpipe.getbyte
    when ADDRESS_FAMILIES[:ipv6] then [:v6c, nil]
    when ADDRESS_FAMILIES[:ipv4] then [:v4w, nil]
    else
      if is_retrying
        error = mutex.synchronize { errors.pop }
        [:failure, error]
      else
        self.after_hostname_resolution_state(rpipe, started_at, timeout, mutex, errors, is_retrying: true)
      end
    end
  end
  private_class_method :after_hostname_resolution_state

  def self.select_connecting_family(state, last_family)
    case state
    when :v46c
      if last_family
        family_name = ADDRESS_FAMILIES.key(last_family)
        ADDRESS_FAMILIES.fetch(ADDRESS_FAMILIES.keys.find { |k| k != family_name })
      else
        ADDRESS_FAMILIES[:ipv6]
      end
    when :v6c, :v4c
      family_name = "ipv#{state.to_s[1]}"
      ADDRESS_FAMILIES[family_name.to_sym]
    end
  end
  private_class_method :select_connecting_family

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
