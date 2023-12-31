require 'socket'

class Socket
  RESOLUTION_DELAY = 0.05
  private_constant :RESOLUTION_DELAY

  PATIENTLY_RESOLUTION_DELAY = 2
  private_constant :PATIENTLY_RESOLUTION_DELAY

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

    hostname_resolution_threads = []
    wait_for_hostname_resolution_patiently = false
    selectable_addrinfos = SelectableAddrinfos.new
    connecting_sockets = ConnectingSockets.new
    connection_attempt_delay_expires_at = nil
    connection_attempt_started_at = nil
    state = :start
    connected_socket = nil
    last_error = nil

    if local_host && local_port
      local_addrinfos = Addrinfo.getaddrinfo(local_host, local_port, nil, :STREAM, nil)
      resolving_family_names = local_addrinfos.map { |lai| ADDRESS_FAMILIES.key(lai.afamily) }
    else
      local_addrinfos = []
      resolving_family_names = ADDRESS_FAMILIES.keys
    end

    hostname_resolution_queue = HostnameResolutionQueue.new(resolving_family_names.size)

    ret = loop do
      case state
      when :start
        hostname_resolution_started_at = current_clocktime
        hostname_resolution_args = [host, port, hostname_resolution_queue]

        hostname_resolution_threads.concat(
          resolving_family_names.map { |family|
            thread_args = [family, *hostname_resolution_args]
            thread = Thread.new(*thread_args) { |*thread_args| hostname_resolution(*thread_args) }
            Thread.pass
            thread
          }
        )

        hostname_resolution_retry_count = resolving_family_names.size - 1

        while hostname_resolution_retry_count >= 0
          remaining = resolv_timeout ? second_to_timeout(hostname_resolution_started_at + resolv_timeout) : nil
          hostname_resolved, _, = IO.select([hostname_resolution_queue.rpipe], nil, nil, remaining)

          unless hostname_resolved # resolv_timeoutでタイムアウトした場合
            state = :timeout # "user specified timeout"
            break
          end

          family_name, res = hostname_resolution_queue.get

          if res.is_a? Exception
            last_error = res unless ignoreable_error?(res)
            if hostname_resolution_retry_count.zero?
              state = :failure
              break
            end
            hostname_resolution_retry_count -= 1
          else
            state = case family_name
                    when :ipv6 then :v6c
                    when :ipv4 then hostname_resolution_queue.rpipe.closed? ? :v4c : :v4w
                    end
            selectable_addrinfos.add(family_name, res)
            last_error = nil # これ以降は接続時のエラーを保存したいので一旦リセット
            break
          end
        end

        next
      when :v4w
        ipv6_resolved, _, = IO.select([hostname_resolution_queue.rpipe], nil, nil, RESOLUTION_DELAY)

        if ipv6_resolved # v6アドレス解決 / 名前解決エラー
          family_name, res = hostname_resolution_queue.get
          selectable_addrinfos.add(family_name, res) unless res.is_a? Exception
          state = :v46c
        else # Resolution delay タイムアウト済み
          state = :v4c
        end

        next
      when :v4c, :v6c, :v46c # v4の場合はv6名前解決中の可能性あり
        connection_attempt_started_at = current_clocktime unless connection_attempt_started_at
        addrinfo = selectable_addrinfos.get
        socket = Socket.new(addrinfo.pfamily, addrinfo.socktype, addrinfo.protocol)

        if local_addrinfos.any?
          local_addrinfo = local_addrinfos.find { |lai| lai.afamily == addrinfo.afamily }

          if local_addrinfo.nil? # Connecting addrinfoと同じアドレスファミリのLocal addrinfoがない
            if selectable_addrinfos.empty? && connecting_sockets.empty? && hostname_resolution_queue.empty?
              if !hostname_resolution_queue.rpipe.closed? && !wait_for_hostname_resolution_patiently
                wait_for_hostname_resolution_patiently = true
                connection_attempt_delay_expires_at = current_clocktime + PATIENTLY_RESOLUTION_DELAY
                state = :v46w
              else
                last_error = SocketError.new 'no appropriate local address'
                state = :failure
              end
            elsif selectable_addrinfos.any?
              # case Selectable addrinfos: any && Connecting sockets: any && Hostname resolution queue: any
              # case Selectable addrinfos: any && Connecting sockets: any && Hostname resolution queue: empty
              # case Selectable addrinfos: any && Connecting sockets: empty && Hostname resolution queue: any
              # case Selectable addrinfos: any && Connecting sockets: empty && Hostname resolution queue: empty
              # Try other Addrinfo in next loop
            else
              # case Selectable addrinfos: empty && Connecting sockets: any && Hostname resolution queue: any
              # case Selectable addrinfos: empty && Connecting sockets: any && Hostname resolution queue: empty
              # case Selectable addrinfos: empty && Connecting sockets: empty && Hostname resolution queue: any
              # case Selectable addrinfos: empty && Connecting sockets: empty && Hostname resolution queue: empty
              # Wait for connection to be established or hostname resolution in next loop
              connection_attempt_delay_expires_at = nil
              state = :v46w
            end
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
            connecting_sockets.add(socket, addrinfo)
            state = :v46w
          end
        rescue SystemCallError => e
          last_error = e
          socket.close unless socket.closed?

          if selectable_addrinfos.empty? && connecting_sockets.empty? && hostname_resolution_queue.empty?
            if !hostname_resolution_queue.rpipe.closed? && !wait_for_hostname_resolution_patiently
              wait_for_hostname_resolution_patiently = true
              connection_attempt_delay_expires_at = current_clocktime + PATIENTLY_RESOLUTION_DELAY
              state = :v46w
            else
              state = :failure
            end
          elsif selectable_addrinfos.any?
            # case Selectable addrinfos: any && Connecting sockets: any   && Hostname resolution queue: any
            # case Selectable addrinfos: any && Connecting sockets: any   && Hostname resolution queue: empty
            # case Selectable addrinfos: any && Connecting sockets: empty && Hostname resolution queue: any
            # case Selectable addrinfos: any && Connecting sockets: empty && Hostname resolution queue: empty
            # Try other Addrinfo in next loop
          else
            # case Selectable addrinfos: empty && Connecting sockets: any   && Hostname resolution queue: any
            # case Selectable addrinfos: empty && Connecting sockets: any   && Hostname resolution queue: empty
            # case Selectable addrinfos: empty && Connecting sockets: empty && Hostname resolution queue: any
            # Wait for connection to be established or hostname resolution in next loop
            connection_attempt_delay_expires_at = nil
            state = :v46w
          end
        end

        next
      when :v46w
        if connect_timeout && second_to_timeout(connection_attempt_started_at + connect_timeout).zero?
          state = :timeout # "user specified timeout"
          next
        end

        remaining = second_to_timeout(connection_attempt_delay_expires_at)
        rpipe = hostname_resolution_queue.rpipe.closed? ? nil : [hostname_resolution_queue.rpipe]
        hostname_resolved, connectable_sockets, = IO.select(rpipe, connecting_sockets.all, nil, remaining)

        if connectable_sockets&.any?
          while (connectable_socket = connectable_sockets.pop)
            begin
              addrinfo = connecting_sockets.delete connectable_socket
              connectable_socket.connect_nonblock(addrinfo) # MinGW対応
            rescue Errno::EISCONN # already connected
              connected_socket = connectable_socket
              connecting_sockets.delete connectable_socket

              connectable_sockets.each do |other_connectable_socket|
                other_connectable_socket.close unless other_connectable_socket.closed?
              end

              state = :success
              break
            rescue => e
              last_error = e
              connectable_socket.close unless connectable_socket.closed?

              next if connectable_sockets.any?

              if selectable_addrinfos.empty? && connecting_sockets.empty? && hostname_resolution_queue.empty?
                if !hostname_resolution_queue.rpipe.closed? && !wait_for_hostname_resolution_patiently
                  wait_for_hostname_resolution_patiently = true
                  connection_attempt_delay_expires_at = current_clocktime + PATIENTLY_RESOLUTION_DELAY
                else
                  state = :failure
                end
              elsif selectable_addrinfos.any?
                # case Selectable addrinfos: any && Connecting sockets: any   && Hostname resolution queue: any
                # case Selectable addrinfos: any && Connecting sockets: any   && Hostname resolution queue: empty
                # case Selectable addrinfos: any && Connecting sockets: empty && Hostname resolution queue: any
                # case Selectable addrinfos: any && Connecting sockets: empty && Hostname resolution queue: empty
                # Wait for connection attempt delay timeout in next loop
              else
                # case Selectable addrinfos: empty && Connecting sockets: any   && Hostname resolution queue: empty
                # case Selectable addrinfos: empty && Connecting sockets: any   && Hostname resolution queue: any
                # case Selectable addrinfos: empty && Connecting sockets: empty && Hostname resolution queue: any
                # Wait for connection to be established or hostname resolution in next loop
                connection_attempt_delay_expires_at = nil
              end
            else # Ubuntu対応
              connected_socket = connectable_socket
              connecting_sockets.delete connectable_socket

              connectable_sockets.each do |other_connectable_socket|
                other_connectable_socket.close unless other_connectable_socket.closed?
              end

              state = :success
              break
            end
          end
        elsif hostname_resolved&.any?
          family_name, res = hostname_resolution_queue.get
          selectable_addrinfos.add(family_name, res) unless res.is_a? Exception
          connection_attempt_delay_expires_at = nil if wait_for_hostname_resolution_patiently
          state = :v46w
        else # Connection Attempt Delayタイムアウト
          if selectable_addrinfos.empty? && connecting_sockets.empty? && hostname_resolution_queue.empty?
            state = :failure
          elsif selectable_addrinfos.any?
            # case Selectable addrinfos: any && Connecting sockets: any && Hostname resolution queue: any
            # case Selectable addrinfos: any && Connecting sockets: empty && Hostname resolution queue: any
            # case Selectable addrinfos: any && Connecting sockets: empty && Hostname resolution queue: any
            # case Selectable addrinfos: any && Connecting sockets: empty && Hostname resolution queue: empty
            # Wait for connection attempt delay timeout in next loop
            state = :v46c
          else
            # case Selectable addrinfos: empty && Connecting sockets: any && Hostname resolution queue: any
            # case Selectable addrinfos: empty && Connecting sockets: empty && Hostname resolution queue: any
            # case Selectable addrinfos: empty && Connecting sockets: any && Hostname resolution queue: empty
            # case Selectable addrinfos: empty && Connecting sockets: empty && Hostname resolution queue: empty
            # Wait for connection to be established or hostname resolution in next loop
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
        yield ret
      ensure
        ret.close
      end
    else
      ret
    end
  ensure
    hostname_resolution_threads.each do |thread|
      thread&.exit
    end

    hostname_resolution_queue.close_all

    connecting_sockets.each do |connecting_socket|
      connecting_socket.close unless connecting_socket.closed?
    end
  end

  def self.hostname_resolution(family, host, port, hostname_resolution_queue)
    begin
      resolved_addrinfos = Addrinfo.getaddrinfo(host, port, ADDRESS_FAMILIES[family], :STREAM)
      hostname_resolution_queue.add_resolved(family, resolved_addrinfos)
    rescue => e
      hostname_resolution_queue.add_error(family, e)
    end
  end
  private_class_method :hostname_resolution

  def self.second_to_timeout(ends_at)
    return 0 unless ends_at

    remaining = (ends_at - current_clocktime)
    remaining.negative? ? 0 : remaining
  end
  private_class_method :second_to_timeout

  def self.current_clocktime
    Process.clock_gettime(Process::CLOCK_MONOTONIC)
  end
  private_class_method :current_clocktime

  class SelectableAddrinfos
    PRIORITY_ON_V6 = [:ipv6, :ipv4]
    PRIORITY_ON_V4 = [:ipv4, :ipv6]

    def initialize
      @addrinfo_dict = {}
      @last_family = nil
    end

    def add(family_name, addrinfos)
      @addrinfo_dict[family_name] = addrinfos
    end

    def get
      return nil if empty?

      precedences = case @last_family
                    when :ipv4, nil then PRIORITY_ON_V6
                    when :ipv6      then PRIORITY_ON_V4
                    end

      precedences.each do |family_name|
        addrinfo = @addrinfo_dict[family_name]&.shift
        next unless addrinfo

        @last_family = family_name
        return addrinfo
      end
    end

    def empty?
      @addrinfo_dict.all? { |_, addrinfos| addrinfos.empty? }
    end

    def any?
      !empty?
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
      return nil if @queue.empty?

      res = nil

      @mutex.synchronize do
        @rpipe.getbyte
        res = @queue.pop
      end

      @taken_count += 1
      close_all if @taken_count == @size
      res
    end

    def empty?
      @queue.empty?
    end

    def close_all
      @queue.close unless @queue.closed?
      @rpipe.close unless @rpipe.closed?
      @wpipe.close unless @wpipe.closed?
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

    def delete(socket)
      @socket_dict.delete socket
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
      e.is_a?(Socket.const_defined?(:EAI_ADDRFAMILY)) &&
        (e.is_a?(Socket::ResolutionError)) &&
        (e.error_code == Socket::EAI_ADDRFAMILY)
    else
      e.is_a?(SocketError) && (e.message == 'getaddrinfo: Address family for hostname not supported')
    end
  end
end

# HOSTNAME = "www.kame.net"
# PORT = 80
HOSTNAME = "localhost"
PORT = 9292

# # 名前解決動作確認用 (Connection Attempt Delay以内の遅延)
# Addrinfo.define_singleton_method(:getaddrinfo) do |_, _, family, *_|
#   if family == Socket::AF_INET6
#     sleep 0.25
#     [Addrinfo.tcp("::1", PORT)]
#   else
#     [Addrinfo.tcp("127.0.0.1", PORT)]
#   end
# end

# # 名前解決動作確認用 (タイムアウト)
# Addrinfo.define_singleton_method(:getaddrinfo) { |*_| sleep }

# # 名前解決動作確認用 (例外)
# Addrinfo.define_singleton_method(:getaddrinfo) do |_, _, family, *_|
#   if family == Socket::AF_INET6
#     [Addrinfo.tcp("::1", PORT)]
#   else
#     # NOTE ignoreされる
#     raise SocketError, 'getaddrinfo: Address family for hostname not supported'
#   end
# end

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
# class Addrinfo
#   class << self
#     alias _getaddrinfo getaddrinfo
#
#     def getaddrinfo(nodename, service, family, *_)
#       if service == 9292
#         if family == Socket::AF_INET6
#           [Addrinfo.tcp("::1", 9292)]
#         else
#           sleep
#         end
#       else
#         _getaddrinfo(nodename, service, family)
#       end
#     end
#   end
# end
#
# Socket.tcp(HOSTNAME, PORT, 'localhost', (32768..61000).to_a.sample) do |socket|
#    socket.write "GET / HTTP/1.0\r\n\r\n"
#    print socket.read
# end

# Socket.tcp(HOSTNAME, PORT) do |socket|
#   socket.write "GET / HTTP/1.0\r\n\r\n"
#   print socket.read
# end
