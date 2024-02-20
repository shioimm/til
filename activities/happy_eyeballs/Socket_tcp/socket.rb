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

  @tcp_fast_fallback = true

  class << self
    attr_accessor :tcp_fast_fallback
  end

  def self.tcp(host, port, local_host = nil, local_port = nil, connect_timeout: nil, resolv_timeout: nil, fast_fallback: tcp_fast_fallback, &block) # :yield: socket
    unless fast_fallback
      return tcp_without_fast_fallback(host, port, local_host, local_port, connect_timeout:, resolv_timeout:, &block)
    end

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

    specified_family_name = nil
    hostname_resolution_threads = []
    hostname_resolution_queue = nil
    hostname_resolution_waiting = nil
    selectable_addrinfos = SelectableAddrinfos.new
    connecting_sockets = ConnectingSockets.new
    local_addrinfos = []
    connection_attempt_delay_expires_at = nil
    connection_attempt_started_at = nil
    state = :start
    connected_socket = nil
    last_error = nil
    is_windows_environment ||= (RUBY_PLATFORM =~ /mswin|mingw|cygwin/)

    ret = loop do
      case state
      when :start
        specified_family_name, next_state = host && specified_family_name_and_next_state(host)

        if local_host && local_port
          specified_family_name, next_state = specified_family_name_and_next_state(local_host) unless specified_family_name
          local_addrinfos = Addrinfo.getaddrinfo(local_host, local_port, ADDRESS_FAMILIES[specified_family_name], :STREAM, timeout: resolv_timeout)
        end

        if specified_family_name
          addrinfos = Addrinfo.getaddrinfo(host, port, ADDRESS_FAMILIES[specified_family_name], :STREAM, timeout: resolv_timeout)
          selectable_addrinfos.add(specified_family_name, addrinfos)
          hostname_resolution_queue = NoHostnameResolutionQueue.new
          state = next_state
          next
        end

        resolving_family_names = ADDRESS_FAMILIES.keys
        hostname_resolution_queue = HostnameResolutionQueue.new(resolving_family_names.size)
        hostname_resolution_waiting = hostname_resolution_queue.waiting_pipe
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
          hostname_resolved, _, = IO.select(hostname_resolution_waiting, nil, nil, remaining)

          unless hostname_resolved # resolv_timeoutでタイムアウトした場合
            state = :timeout # "user specified timeout"
            break
          end

          family_name, res = hostname_resolution_queue.get

          if res.is_a? Exception
            unless ignoreable_error?(res)
              last_error = res
            end

            if hostname_resolution_retry_count.zero?
              state = :failure
              break
            end
            hostname_resolution_retry_count -= 1
          else
            state = case family_name
                    when :ipv6 then :v6c
                    when :ipv4 then hostname_resolution_queue.closed? ? :v4c : :v4w
                    end
            selectable_addrinfos.add(family_name, res)
            last_error = nil # これ以降は接続時のエラーを保存したいので一旦リセット
            break
          end
        end

        next
      when :v4w
        ipv6_resolved, _, = IO.select(hostname_resolution_waiting, nil, nil, RESOLUTION_DELAY)

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

        if local_addrinfos.any?
          local_addrinfo = local_addrinfos.find { |lai| lai.afamily == addrinfo.afamily }

          if local_addrinfo.nil? # Connecting addrinfoと同じアドレスファミリのLocal addrinfoがない
            if selectable_addrinfos.empty? && connecting_sockets.empty? && hostname_resolution_queue.closed?
              last_error = SocketError.new 'no appropriate local address'
              state = :failure
            elsif resolv_timeout && hostname_resolution_queue.opened?
              # TODO
              #   resolv_timeoutを過ぎていたらtimeout、過ぎていなかったらexpires_atに期限を設定してv46w
              #   connection_attempt_delay_expires_atをrenameする
            elsif selectable_addrinfos.any?
              # case Selectable addrinfos: any && Connecting sockets: any   && Hostname resolution queue: opened
              # case Selectable addrinfos: any && Connecting sockets: any   && Hostname resolution queue: closed
              # case Selectable addrinfos: any && Connecting sockets: empty && Hostname resolution queue: opened
              # case Selectable addrinfos: any && Connecting sockets: empty && Hostname resolution queue: closed
              # Try other Addrinfo in next loop
            else
              # case Selectable addrinfos: empty && Connecting sockets: any   && Hostname resolution queue: opened
              # case Selectable addrinfos: empty && Connecting sockets: any   && Hostname resolution queue: closed
              # case Selectable addrinfos: empty && Connecting sockets: empty && Hostname resolution queue: opened
              # Wait for connection to be established or hostname resolution in next loop
              connection_attempt_delay_expires_at = nil
              state = :v46w
            end
            next
          end
        end

        connection_attempt_delay_expires_at = current_clocktime + CONNECTION_ATTEMPT_DELAY

        begin
          result = if specified_family_name && selectable_addrinfos.empty? &&
                       connecting_sockets.empty? && hostname_resolution_queue.closed?
                     local_addrinfo ?
                       addrinfo.connect_from(local_addrinfo, timeout: connect_timeout) :
                       addrinfo.connect(timeout: connect_timeout)
                   else
                     socket = Socket.new(addrinfo.pfamily, addrinfo.socktype, addrinfo.protocol)
                     socket.bind(local_addrinfo) if local_addrinfo
                     socket.connect_nonblock(addrinfo, exception: false)
                   end

          case result
          when 0
            connected_socket = socket
            state = :success
          when Socket
            connected_socket = result
            state = :success
          when :wait_writable # 接続試行中
            connecting_sockets.add(socket, addrinfo)
            state = :v46w
          end
        rescue SystemCallError => e
          last_error = e
          socket.close if socket && !socket.closed?

          if selectable_addrinfos.empty? && connecting_sockets.empty? && hostname_resolution_queue.closed?
            state = :failure
          elsif resolv_timeout && hostname_resolution_queue.opened?
            # TODO
            #   resolv_timeoutを過ぎていたらtimeout、過ぎていなかったらexpires_atに期限を設定してv46w
            #   connection_attempt_delay_expires_atをrenameする
          elsif selectable_addrinfos.any?
            # case Selectable addrinfos: any && Connecting sockets: any   && Hostname resolution queue: any
            # case Selectable addrinfos: any && Connecting sockets: any   && Hostname resolution queue: empty
            # case Selectable addrinfos: any && Connecting sockets: empty && Hostname resolution queue: any
            # case Selectable addrinfos: any && Connecting sockets: empty && Hostname resolution queue: empty
            # Try other Addrinfo in next loop
          else
            # case Selectable addrinfos: empty && Connecting sockets: any   && Hostname resolution queue: opened
            # case Selectable addrinfos: empty && Connecting sockets: any   && Hostname resolution queue: closed
            # case Selectable addrinfos: empty && Connecting sockets: empty && Hostname resolution queue: opened
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
        hostname_resolution_waiting = hostname_resolution_waiting && hostname_resolution_queue.closed? ? nil : hostname_resolution_waiting
        hostname_resolved, connectable_sockets, = IO.select(hostname_resolution_waiting, connecting_sockets.all, nil, remaining)

        if connectable_sockets&.any?
          while (connectable_socket = connectable_sockets.pop)
            is_connected =
              if is_windows_environment
                sockopt = connectable_socket.getsockopt(Socket::SOL_SOCKET, Socket::SO_CONNECT_TIME)
                sockopt.unpack('i').first >= 0
              else
                sockopt = connectable_socket.getsockopt(Socket::SOL_SOCKET, Socket::SO_ERROR)
                sockopt.int.zero?
              end

            if is_connected
              connected_socket = connectable_socket
              connecting_sockets.delete connectable_socket
              connectable_sockets.each do |other_connectable_socket|
                other_connectable_socket.close unless other_connectable_socket.closed?
              end
              state = :success
              break
            else
              failed_ai = connecting_sockets.delete connectable_socket
              inspected_ip_address = failed_ai.ipv6? ? "[#{failed_ai.ip_address}]" : failed_ai.ip_address
              last_error = SystemCallError.new("connect(2) for #{inspected_ip_address}:#{failed_ai.ip_port}", sockopt.int)
              connectable_socket.close unless connectable_socket.closed?

              next if connectable_sockets.any?

              if selectable_addrinfos.empty? && connecting_sockets.empty? && hostname_resolution_queue.closed?
                state = :failure
              elsif resolv_timeout && hostname_resolution_queue.opened?
                # TODO
                #   resolv_timeoutを過ぎていたらtimeout、過ぎていなかったらexpires_atに期限を設定してv46w
                #   connection_attempt_delay_expires_atをrenameする
              elsif selectable_addrinfos.any?
                # case Selectable addrinfos: any && Connecting sockets: any   && Hostname resolution queue: opened
                # case Selectable addrinfos: any && Connecting sockets: any   && Hostname resolution queue: closed
                # case Selectable addrinfos: any && Connecting sockets: empty && Hostname resolution queue: opened
                # case Selectable addrinfos: any && Connecting sockets: empty && Hostname resolution queue: closed
                # Wait for connection attempt delay timeout in next loop
              else
                # case Selectable addrinfos: empty && Connecting sockets: any   && Hostname resolution queue: closed
                # case Selectable addrinfos: empty && Connecting sockets: any   && Hostname resolution queue: opened
                # case Selectable addrinfos: empty && Connecting sockets: empty && Hostname resolution queue: opened
                # Wait for connection to be established or hostname resolution in next loop
                connection_attempt_delay_expires_at = nil
              end
            end
          end
        elsif hostname_resolved&.any?
          family_name, res = hostname_resolution_queue.get
          selectable_addrinfos.add(family_name, res) unless res.is_a? Exception
        else # Connection Attempt Delayタイムアウト
          if selectable_addrinfos.empty? && connecting_sockets.empty? && hostname_resolution_queue.closed?
            state = :failure
          elsif selectable_addrinfos.any?
            # case Selectable addrinfos: any && Connecting sockets: any   && Hostname resolution queue: opened
            # case Selectable addrinfos: any && Connecting sockets: empty && Hostname resolution queue: opened
            # case Selectable addrinfos: any && Connecting sockets: empty && Hostname resolution queue: opened
            # case Selectable addrinfos: any && Connecting sockets: empty && Hostname resolution queue: closed
            # Try other Addrinfo in next loop
            state = :v46c
          else
            # case Selectable addrinfos: empty && Connecting sockets: any   && Hostname resolution queue: opened
            # case Selectable addrinfos: empty && Connecting sockets: empty && Hostname resolution queue: opened
            # case Selectable addrinfos: empty && Connecting sockets: any   && Hostname resolution queue: closed
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
    if fast_fallback
      hostname_resolution_threads.each do |thread|
        thread&.exit
      end

      hostname_resolution_queue&.close_all

      connecting_sockets.each do |connecting_socket|
        connecting_socket.close unless connecting_socket.closed?
      end
    end
  end

  def self.specified_family_name_and_next_state(hostname)
    if    hostname.match?(/:/)                             then [:ipv6, :v6c]
    elsif hostname.match?(/^([0-9]{1,3}\.){3}[0-9]{1,3}$/) then [:ipv4, :v4c]
    end
  end
  private_class_method :specified_family_name_and_next_state

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

      if @addrinfo_dict.size == 1
        @addrinfo_dict.each { |_, addrinfos| return addrinfos.shift }
      end

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

  class NoHostnameResolutionQueue
    def waiting_pipe
      nil
    end

    def add_resolved(_, _)
      raise StandardError, "This #{self.class} cannot respond to:"
    end

    def add_error(_, _)
      raise StandardError, "This #{self.class} cannot respond to:"
    end

    def get
      nil
    end

    def closed?
      true
    end

    def close_all
      # Do nothing
    end
  end
  private_constant :NoHostnameResolutionQueue

  class HostnameResolutionQueue
    def initialize(size)
      @size = size
      @taken_count = 0
      @rpipe, @wpipe = IO.pipe
      @queue = Queue.new
      @mutex = Mutex.new
    end

    def waiting_pipe
      [@rpipe]
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

    def closed?
      @rpipe.closed?
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

  def self.tcp_without_fast_fallback(host, port, local_host, local_port, connect_timeout:, resolv_timeout:, &block)
    last_error = nil
    ret = nil

    local_addr_list = nil
    if local_host != nil || local_port != nil
      local_addr_list = Addrinfo.getaddrinfo(local_host, local_port, nil, :STREAM, nil)
    end

    Addrinfo.foreach(host, port, nil, :STREAM, timeout: resolv_timeout) {|ai|
      if local_addr_list
        local_addr = local_addr_list.find {|local_ai| local_ai.afamily == ai.afamily }
        next unless local_addr
      else
        local_addr = nil
      end
      begin
        sock = local_addr ?
          ai.connect_from(local_addr, timeout: connect_timeout) :
          ai.connect(timeout: connect_timeout)
      rescue SystemCallError
        last_error = $!
        next
      end
      ret = sock
      break
    }
    unless ret
      if last_error
        raise last_error
      else
        raise SocketError, "no appropriate local address"
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
  private_class_method :tcp_without_fast_fallback

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

HOSTNAME = "localhost"
PORT = 9292

# HOSTNAME = "www.ruby-lang.org"
# PORT = 80

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
#           [Addrinfo.tcp("127.0.0.1", 9292)]
#         end
#       else
#         _getaddrinfo(nodename, service, family)
#       end
#     end
#   end
# end
#
# local_ip = Socket.ip_address_list.detect { |addr| addr.ipv4? && !addr.ipv4_loopback? }.ip_address
#
# Socket.tcp(HOSTNAME, PORT, local_ip, 0) do |socket|
#    socket.write "GET / HTTP/1.0\r\n\r\n"
#    print socket.read
# end

Socket.tcp(HOSTNAME, PORT, fast_fallback: false) do |socket|
  socket.write "GET / HTTP/1.0\r\n\r\n"
  print socket.read
end

# Socket.tcp(HOSTNAME, PORT) do |socket|
#   socket.write "GET / HTTP/1.0\r\n\r\n"
#   print socket.read
# end
