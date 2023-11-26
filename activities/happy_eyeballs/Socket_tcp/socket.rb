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

  HOSTNAME_RESOLUTION_FAILED = 0
  private_constant :HOSTNAME_RESOLUTION_FAILED

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
    resolved_addrinfos_queue = Queue.new
    selectable_addrinfos = SelectableAddrinfos.new

    connecting_sockets = []
    connection_attempt_delay_expires_at = nil
    connection_attempt_started_at = nil
    connecting_sock_ai_pairs = {}
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
          [host, port, resolved_addrinfos_queue, mutex, hostname_resolution_write_pipe, hostname_resolution_errors]

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
          hostname_resolution_threads.size - 1,
        )
        # 先にv4の名前解決に成功 -> v4w
        # 先にv6の名前解決に成功 -> v6c
        # resolv_timeout -> timeout
        # 両方エラー -> failure

        update_selectable_addrinfos(resolved_addrinfos_queue, selectable_addrinfos) if %i[v6c v4w].include? state
        next
      when :v4w
        ipv6_resolved, _, = IO.select([hostname_resolution_read_pipe], nil, nil, RESOLUTION_DELAY)

        if ipv6_resolved # v4/v6共に名前解決済み
          update_selectable_addrinfos(resolved_addrinfos_queue, selectable_addrinfos)

          if hostname_resolution_threads.size == selectable_addrinfos.size
            close_fds(hostname_resolution_read_pipe, hostname_resolution_write_pipe)
            v46w_read_pipe = nil
          end

          state = :v46c
        else # v6はまだ名前解決中
          state = :v4c
        end

        next
      when :v4c, :v6c, :v46c
        connection_attempt_started_at = current_clocktime unless connection_attempt_started_at
        addrinfo = selectable_addrinfos.get
        socket = Socket.new(addrinfo.pfamily, addrinfo.socktype, addrinfo.protocol)

        if local_addrinfos.any?
          local_addrinfo = local_addrinfos.find { |lai| lai.afamily == addrinfo.afamily }

          if local_addrinfo
            socket.bind(local_addrinfo)
          elsif !local_addrinfo && hostname_resolution_threads.size == selectable_addrinfos.size
            last_error = SocketError.new 'no appropriate local address'
            state = :failure
            next
          end
        end

        connection_attempt_delay_expires_at = current_clocktime + CONNECTION_ATTEMPT_DELAY

        begin
          case socket.connect_nonblock(addrinfo, exception: false)
          when 0
            connected_socket = socket
            state = :success
          when :wait_writable # 接続試行中
            connecting_sockets.push socket
            connecting_sock_ai_pairs[socket] = addrinfo
            state = :v46w
          end
        rescue SystemCallError => e
          last_error = e
          socket.close unless socket.closed?

          if selectable_addrinfos.out_of_stock? # 他に試行できるaddrinfosがない
            state = :failure
            next
          end
        end

        last_connecting_family = addrinfo.afamily
        next
      when :v46w
        if connect_timeout && second_to_connection_timeout(connection_attempt_started_at + connect_timeout).zero?
          state = :timeout # "user specified timeout"
          next
        end

        remaining_second = second_to_connection_timeout(connection_attempt_delay_expires_at)
        hostname_resolved, connectable_sockets, = IO.select(v46w_read_pipe, connecting_sockets, nil, remaining_second)

        if connectable_sockets&.any?
          while (connectable_socket = connectable_sockets.pop)
            begin
              target_socket = connecting_sockets.delete(connectable_socket)
              target_socket.connect_nonblock(connecting_sock_ai_pairs[target_socket])
            rescue Errno::EISCONN # already connected
              connected_socket = target_socket
              state = :success
            rescue => e
              last_error = e
              target_socket.close unless target_socket.closed?

              next if connectable_sockets.any?

              if selectable_addrinfos.out_of_stock? && connecting_sockets.empty?
                # 試行できるaddrinfoがなく、接続中のソケットもない場合
                state = :failure
              elsif selectable_addrinfos.out_of_stock?
                # 試行できるaddrinfosがなく、接続中のソケットはある場合 -> 接続中のソケットを待機する
                state = :v46w
                connection_attempt_delay_expires_at = nil
              else
                # 試行できるaddrinfosがある場合 (+ 接続中のソケットがある場合も)
                # -> 次のループに進む。次のループでConnection Attempt Delay タイムアウトしたらv46cへ
                state = :v46w
              end
            ensure
              connecting_sock_ai_pairs.reject! { |s, _| s == target_socket }
            end
          end
        elsif hostname_resolved&.any?
          update_selectable_addrinfos(resolved_addrinfos_queue, selectable_addrinfos)

          if hostname_resolution_threads.size == selectable_addrinfos.size
            close_fds(hostname_resolution_read_pipe, hostname_resolution_write_pipe)
            v46w_read_pipe = nil
          end

          state = :v46w
        else # Connection Attempt Delayタイムアウト
          if !selectable_addrinfos.out_of_stock? # 試行できるaddrinfosが残っている場合
            state = :v46c
          else # 試行できるaddrinfosが残っておらずあとはもう待つしかできない場合
            state = :v46w
            connection_attempt_delay_expires_at = nil
          end
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

    close_fds(hostname_resolution_read_pipe, hostname_resolution_write_pipe, *connecting_sockets)
  end

  def self.hostname_resolution(family, host, port, addrinfos, mutex, wpipe, errors_queue)
    begin
      resolved_addrinfos = Addrinfo.getaddrinfo(host, port, ADDRESS_FAMILIES[family], :STREAM)

      mutex.synchronize do
        addrinfos.push [family, resolved_addrinfos]
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
          addrinfos.push [family, []]
          errors_queue.push e
          wpipe.putc HOSTNAME_RESOLUTION_FAILED
        end
      end
    end
  end
  private_class_method :hostname_resolution

  def self.after_hostname_resolution_state(rpipe, started_at, timeout, mutex, errors_queue, retry_count)
    remaining_second = timeout ? second_to_connection_timeout(started_at + timeout) : nil
    hostname_resolved, _, = IO.select([rpipe], nil, nil, remaining_second)

    unless hostname_resolved # resolv_timeoutでタイムアウトした場合
      return [:timeout, nil] # "user specified timeout"
    end

    case rpipe.getbyte
    when ADDRESS_FAMILIES[:ipv6] then [:v6c, nil]
    when ADDRESS_FAMILIES[:ipv4] then [:v4w, nil]
    when HOSTNAME_RESOLUTION_FAILED
      if retry_count.zero?
        error = errors_queue.pop
        [:failure, error]
      else
        self.after_hostname_resolution_state(rpipe, started_at, timeout, mutex, errors_queue, retry_count - 1)
      end
    end
  end
  private_class_method :after_hostname_resolution_state

  def self.update_selectable_addrinfos(resolved_addrinfos_queue, selectable_addrinfos)
    family_name, addrinfos = resolved_addrinfos_queue.pop
    selectable_addrinfos.add(family_name, addrinfos)
  end
  private_class_method :update_selectable_addrinfos

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

  def self.close_fds(*fds)
    fds.each do |fd|
      begin
        fd.close if fd && !fd.closed?
      rescue
        # ignore error
      end
    end
  end
  private_class_method :close_fds

  class SelectableAddrinfos
    def initialize
      @addrinfo_dict = {}
      @last_family = nil
    end

    def add(family_name, addrinfos)
      @addrinfo_dict[family_name] = addrinfos
    end

    def get
      case @last_family
      when :ipv4, nil
        precedences = [:ipv6, :ipv4]
      when :ipv6
        precedences = [:ipv4, :ipv6]
      end

      precedences.each do |family_name|
        addrinfo = @addrinfo_dict[family_name]&.shift

        if addrinfo
          @last_family = family_name
          return addrinfo
        end
      end
    end

    def out_of_stock?
      @addrinfo_dict.all?{ |_, addrinfos| addrinfos.empty? }
    end

    def size
      @addrinfo_dict.size
    end
  end
end

# HOSTNAME = "www.kame.net"
# PORT = 80
HOSTNAME = "localhost"
PORT = 9292
#
# # # 名前解決動作確認用 (遅延)
# # Addrinfo.define_singleton_method(:getaddrinfo) do |_, _, family, *_|
# #   if family == Socket::AF_INET6
# #     sleep 0.25
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
# 名前解決動作確認用 (複数)
Addrinfo.define_singleton_method(:getaddrinfo) do |_, _, family, *_|
  if family == Socket::AF_INET6
    [Addrinfo.tcp("::1", PORT), Addrinfo.tcp("::1", PORT)]
  else
    sleep 0.1
    [Addrinfo.tcp("127.0.0.1", PORT)]
  end
end
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
