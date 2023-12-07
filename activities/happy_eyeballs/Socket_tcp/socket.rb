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

  HOSTNAME_RESOLUTION_QUEUE_UPDATED = 0
  private_constant :HOSTNAME_RESOLUTION_QUEUE_UPDATED

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

    hostname_resolution_threads = []
    selectable_addrinfos = SelectableAddrinfos.new
    connecting_sockets = []
    connection_attempt_delay_expires_at = nil
    connection_attempt_started_at = nil
    connecting_sock_ai_pairs = {}

    resolving_family_names, local_addrinfos =
      if local_host && local_port
        local_addrinfos = Addrinfo.getaddrinfo(local_host, local_port, nil, :STREAM, nil)
        resolving_family_names = local_addrinfos.map { |lai| ADDRESS_FAMILIES.key(lai.afamily) }

        [resolving_family_names, local_addrinfos]
      else
        [ADDRESS_FAMILIES.keys, []]
      end

    hostname_resolution_queue = HostnameResolutionQueue.new(resolving_family_names.size)

    connected_socket = loop do
      case state
      when :start
        hostname_resolution_started_at = current_clocktime
        hostname_resolution_args = [host, port, hostname_resolution_queue]

        hostname_resolution_threads.concat(
          resolving_family_names.map { |family|
            thread_args = [family].concat hostname_resolution_args
            Thread.new(*thread_args) { |*thread_args| hostname_resolution(*thread_args) }
          }
        )

        hostname_resolution_retry_count = hostname_resolution_threads.size - 1

        while hostname_resolution_retry_count >= 0
          remaining_second =
            resolv_timeout ? second_to_connection_timeout(hostname_resolution_started_at + resolv_timeout) : nil

          hostname_resolved, _, = IO.select([hostname_resolution_queue.rpipe], nil, nil, remaining_second)

          unless hostname_resolved # resolv_timeoutでタイムアウトした場合
            state = :timeout # "user specified timeout"
            break
          end

          family_name, res = hostname_resolution_queue.get

          if res.is_a? Array # Addrinfoの配列
            state =
              case family_name
              when :ipv6 then :v6c
              when :ipv4 then last_error.nil? ? :v4w : :v4c
            end
          else # 例外
            last_error = res
            state = :failure if hostname_resolution_retry_count.zero?
            hostname_resolution_retry_count -= 1
          end

          if %i[v6c v4w v4c].include? state
            selectable_addrinfos.add(family_name, res)
            break
          end
        end

        next
      when :v4w
        ipv6_resolved, _, = IO.select([hostname_resolution_queue.rpipe], nil, nil, RESOLUTION_DELAY)

        if ipv6_resolved # v4/v6共に名前解決済み
          family_name, res = hostname_resolution_queue.get
          selectable_addrinfos.add(family_name, res) if res.is_a? Array
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

          if local_addrinfo.nil? && hostname_resolution_queue.empty?
            last_error = SocketError.new 'no appropriate local address'
            state = :failure
            next
          end

          socket.bind(local_addrinfo)
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

        next
      when :v46w
        if connect_timeout && second_to_connection_timeout(connection_attempt_started_at + connect_timeout).zero?
          state = :timeout # "user specified timeout"
          next
        end

        remaining_second = second_to_connection_timeout(connection_attempt_delay_expires_at)
        v46w_rpipe = hostname_resolution_queue.rpipe.closed? ? nil : [hostname_resolution_queue.rpipe]
        hostname_resolved, connectable_sockets, = IO.select(v46w_rpipe, connecting_sockets, nil, remaining_second)

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
          family_name, res = hostname_resolution_queue.get
          selectable_addrinfos.add(family_name, res) if res.is_a? Array
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

    connecting_sockets.each do |connecting_socket|
      begin
        connecting_socket.close if !connecting_socket.closed?
      rescue
        # ignore
      end
    end
  end

  def self.hostname_resolution(family, host, port, hostname_resolution_queue)
    begin
      resolved_addrinfos = Addrinfo.getaddrinfo(host, port, ADDRESS_FAMILIES[family], :STREAM)
      hostname_resolution_queue.add_resolved(family, resolved_addrinfos)
    rescue => e
      if ignoreable_error?(e) # 動作確認用
        # ignore
      else
        hostname_resolution_queue.add_error(family, e)
      end
    end
  end
  private_class_method :hostname_resolution

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
  private_constant :SelectableAddrinfos

  class HostnameResolutionQueue
    attr_reader :rpipe

    def initialize(size)
      @size = size
      @taken_count = 0
      @rpipe, @wpipe = IO.pipe
      @queue = Queue.new
      @mutex = Mutex.new
    end

    def add_resolved(family, resolved_addrinfos)
      @mutex.synchronize do
        @queue.push [family, resolved_addrinfos]
        @wpipe.putc HOSTNAME_RESOLUTION_QUEUE_UPDATED
      end
    end

    def add_error(family, error)
      @mutex.synchronize do
        @queue.push [family, error]
        @wpipe.putc HOSTNAME_RESOLUTION_QUEUE_UPDATED
      end
    end

    def get
      res = nil

      @mutex.synchronize do
        @rpipe.getbyte
        res = @queue.pop
      end

      @taken_count += 1

      if @taken_count == @size
        @queue.close
        @rpipe.close
        @wpipe.close
      end

      res
    end
  end
  private_constant :HostnameResolutionQueue

  class ConnectingSockets
    def initialize
      @socket_dict = {}
    end

    def all
      @socket_dict.keys
    end

    def add(socket, addrinfo)
      @socket_dict[socket] = addrinfo
    end

    def nonblocking_connect(socket)
      addrinfo = @socket_dict.delete socket
      socket.connect_nonblock(addrinfo)
    end

    def empty?
      @socket_dict.empty?
    end

    def each
      @socket_dict.keys.each do |socket|
        yield socket
      end
    end
  end
  private_constant :ConnectingSockets

  def self.ignoreable_error?(e)
    if ENV['RBENV_VERSION'].to_f > 3.3
      return false unless e.is_a? Socket::ResolutionError

      [
        Socket::EAI_AGAIN,      # when IPv6 is not supported↲
        Socket::EAI_ADDRFAMILY, # when timed out (EAI_AGAIN)
      ].include?(e.error_code)
    else
      return false unless e.is_a? SocketError

      [
        'getaddrinfo: Address family for hostname not supported', # when IPv6 is not supported
        'getaddrinfo: Temporary failure in name resolution',      # when timed out (EAI_AGAIN)
      ].include?(e.message)
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
# # 名前解決動作確認用 (複数)
# Addrinfo.define_singleton_method(:getaddrinfo) do |_, _, family, *_|
#   if family == Socket::AF_INET6
#     [Addrinfo.tcp("::1", PORT), Addrinfo.tcp("::1", PORT)]
#   else
#     sleep 0.1
#     [Addrinfo.tcp("127.0.0.1", PORT)]
#   end
# end

# # local_host / local_port を指定する場合
# Socket.tcp(HOSTNAME, PORT, 'localhost', (32768..61000).to_a.sample) do |socket|
#   socket.write "GET / HTTP/1.0\r\n\r\n"
#   print socket.read
# end

# Socket.tcp(HOSTNAME, PORT) do |socket|
#   socket.write "GET / HTTP/1.0\r\n\r\n"
#   print socket.read
# end
