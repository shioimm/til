require 'socket'

class Socket
  DEBUG = true

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

  IPV6_ADRESS_FORMAT = /(?i)(?:(?:[0-9A-F]{1,4}:){7}(?:[0-9A-F]{1,4}|:)|(?:[0-9A-F]{1,4}:){6}(?:[0-9A-F]{1,4}::[0-9A-F]{1,4}|:(?:[0-9A-F]{1,4}:){1,5}[0-9A-F]{1,4}|:)|(?:[0-9A-F]{1,4}:){5}(?::[0-9A-F]{1,4}::[0-9A-F]{1,4}|:(?:[0-9A-F]{1,4}:){1,4}[0-9A-F]{1,4}|:)|(?:[0-9A-F]{1,4}:){4}(?::[0-9A-F]{1,4}::[0-9A-F]{1,4}|:(?:[0-9A-F]{1,4}:){1,3}[0-9A-F]{1,4}|:)|(?:[0-9A-F]{1,4}:){3}(?::[0-9A-F]{1,4}::[0-9A-F]{1,4}|:(?:[0-9A-F]{1,4}:){1,2}[0-9A-F]{1,4}|:)|(?:[0-9A-F]{1,4}:){2}(?::[0-9A-F]{1,4}::[0-9A-F]{1,4}|:(?:[0-9A-F]{1,4}:)[0-9A-F]{1,4}|:)|(?:[0-9A-F]{1,4}:){1}(?::[0-9A-F]{1,4}::[0-9A-F]{1,4}|::(?:[0-9A-F]{1,4}:){1,5}[0-9A-F]{1,4}|:)|::(?:[0-9A-F]{1,4}::[0-9A-F]{1,4}|:(?:[0-9A-F]{1,4}:){1,6}[0-9A-F]{1,4}|:))(?:%.+)?/
  private_constant :IPV6_ADRESS_FORMAT

  @tcp_fast_fallback = true

  class << self
    attr_accessor :tcp_fast_fallback
  end

  def self.tcp(host, port, local_host = nil, local_port = nil, connect_timeout: nil, resolv_timeout: nil, fast_fallback: tcp_fast_fallback, &block) # :yield: socket
    sock = if fast_fallback && !(host && ip_address?(host))
      tcp_with_fast_fallback(host, port, local_host, local_port, connect_timeout:, resolv_timeout:, &block)
    else
      tcp_without_fast_fallback(host, port, local_host, local_port, connect_timeout:, resolv_timeout:, &block)
    end

    if block_given?
      begin
        yield sock
      ensure
        sock.close
      end
    else
      sock
    end
  end

  def self.tcp_with_fast_fallback(host, port, local_host = nil, local_port = nil, connect_timeout: nil, resolv_timeout: nil)
    if local_host && local_port
      local_addrinfos = Addrinfo.getaddrinfo(local_host, local_port, nil, :STREAM, timeout: resolv_timeout)
      resolving_family_names = local_addrinfos.map { |lai| ADDRESS_FAMILIES.key(lai.afamily) }.uniq
    else
      local_addrinfos = []
      resolving_family_names = ADDRESS_FAMILIES.keys
    end

    hostname_resolution_threads = []
    resolved_addrinfos = ResolvedAddrinfos.new
    connecting_sockets = ConnectingSockets.new
    is_windows_environment ||= (RUBY_PLATFORM =~ /mswin|mingw|cygwin/)

    now = current_clock_time
    resolution_delay_expires_at = nil
    connection_attempt_delay_expires_at = nil
    user_specified_connect_timeout_at = nil
    last_error = nil

    if (is_single_family = resolving_family_names.size.eql?(1))
      family_name = resolving_family_names.first
      addrinfos = Addrinfo.getaddrinfo(host, port, family_name, :STREAM, timeout: resolv_timeout)
      resolved_addrinfos.add(family_name, addrinfos)
      hostname_resolution_queue = nil
      hostname_resolution_waiting = nil
      user_specified_resolv_timeout_at = nil
    else
      hostname_resolution_queue = HostnameResolutionQueue.new(resolving_family_names.size)
      hostname_resolution_waiting = hostname_resolution_queue.waiting_pipe

      hostname_resolution_threads.concat(
        resolving_family_names.map { |family|
          thread_args = [family, host, port, hostname_resolution_queue]
          thread = Thread.new(*thread_args) { |*thread_args| hostname_resolution(*thread_args) }
          Thread.pass
          thread
        }
      )

      user_specified_resolv_timeout_at = resolv_timeout ? now + resolv_timeout : nil
    end

    count = 0 if DEBUG # for DEBUGging

    loop do
      count += 1 if DEBUG # for DEBUGging

      puts "[DEBUG] #{count}: ** Check for readying to connect **" if DEBUG
      puts "[DEBUG] #{count}: resolved_addrinfos #{resolved_addrinfos.instance_variable_get(:"@addrinfo_dict")}" if DEBUG
      puts "[DEBUG] #{count}: expired?(now, user_specified_connect_timeout_at) #{expired?(now, user_specified_connect_timeout_at)}" if DEBUG
      puts "[DEBUG] #{count}: resolved_addrinfos.resolved?(:ipv6) #{resolved_addrinfos.resolved?(:ipv6)}" if DEBUG
      puts "[DEBUG] #{count}: resolved_addrinfos.resolved?(:ipv4) #{resolved_addrinfos.resolved?(:ipv4)}" if DEBUG
      puts "[DEBUG] #{count}: expired?(now, resolution_delay_expires_at) #{expired?(now, resolution_delay_expires_at)}" if DEBUG

      if resolved_addrinfos.any? &&
          (expired?(now, connection_attempt_delay_expires_at) ||
           (resolved_addrinfos.resolved?(:ipv6) ||
            expired?(now, resolution_delay_expires_at) ||
            (connection_attempt_delay_expires_at.nil? && is_single_family)))

        resolution_delay_expires_at = nil if resolution_delay_expires_at

        puts "[DEBUG] #{count}: ** Start to connect **" if DEBUG
        puts "[DEBUG] #{count}: resolved_addrinfos #{resolved_addrinfos.instance_variable_get(:"@addrinfo_dict")}"  if DEBUG
        while (addrinfo = resolved_addrinfos.get)
          puts "[DEBUG] #{count}: Get #{addrinfo.ip_address} as a destination address" if DEBUG

          if local_addrinfos.any?
            puts "[DEBUG] #{count}: local_addrinfos #{local_addrinfos}" if DEBUG
            local_addrinfo = local_addrinfos.find { |lai| lai.afamily == addrinfo.afamily }

            if local_addrinfo.nil? # Connecting addrinfoと同じアドレスファミリのLocal addrinfoがない
              if resolved_addrinfos.any?
                # Try other Addrinfo in next "while"
                next
              elsif connecting_sockets.any? || !resolved_addrinfos.resolved_all?(resolving_family_names)
                # Exit this "while" and wait for connections to be established or hostname resolution in next loop
                # Or exit this "while" and wait for hostname resolution in next loop
                break
              else
                raise SocketError.new 'no appropriate local address'
              end
            end
          end

          puts "[DEBUG] #{count}: Start to connect to #{addrinfo.ip_address}" if DEBUG

          begin
            if resolved_addrinfos.any? || connecting_sockets.any? || !resolved_addrinfos.resolved_all?(resolving_family_names)
              socket = Socket.new(addrinfo.pfamily, addrinfo.socktype, addrinfo.protocol)
              socket.bind(local_addrinfo) if local_addrinfo
              result = socket.connect_nonblock(addrinfo, exception: false)
              connection_attempt_delay_expires_at = now + CONNECTION_ATTEMPT_DELAY
            else
              result = socket = local_addrinfo ?
                addrinfo.connect_from(local_addrinfo, timeout: connect_timeout) :
                addrinfo.connect(timeout: connect_timeout)
            end

            case result
            when 0, Socket
              return socket
            when :wait_writable # 接続試行中
              connecting_sockets.add(socket, addrinfo)
              break
            end
          rescue SystemCallError => e
            socket&.close
            last_error = $!

            if resolved_addrinfos.any?
              # Try other Addrinfo in next "while"
              next
            elsif connecting_sockets.any? || !resolved_addrinfos.resolved_all?(resolving_family_names)
              # Exit this "while" and wait for connections to be established or hostname resolution in next loop
              # Or exit this "while" and wait for hostname resolution in next loop
            else
              raise last_error
            end
          end

          if resolved_addrinfos.empty? && connecting_sockets.any?
            connection_attempt_delay_expires_at = nil
            user_specified_connect_timeout_at = now + connect_timeout if connect_timeout
          end
        end
      end

      puts "[DEBUG] #{count}: connecting_sockets #{connecting_sockets.all}" if DEBUG
      puts "[DEBUG] #{count}: last error #{last_error&.message|| 'nil'}" if DEBUG

      ends_at =
        [resolution_delay_expires_at, connection_attempt_delay_expires_at].compact.min ||
        [user_specified_resolv_timeout_at, user_specified_connect_timeout_at].compact.max
      puts "[DEBUG] #{count}: resolution_delay_expires_at #{resolution_delay_expires_at || 'nil'}" if DEBUG
      puts "[DEBUG] #{count}: connection_attempt_delay_expires_at #{connection_attempt_delay_expires_at || 'nil'}" if DEBUG
      puts "[DEBUG] #{count}: user_specified_resolv_timeout_at #{user_specified_resolv_timeout_at || 'nil'}" if DEBUG
      puts "[DEBUG] #{count}: user_specified_connect_timeout_at #{user_specified_connect_timeout_at || 'nil'}" if DEBUG
      puts "[DEBUG] #{count}: ends_at #{ends_at || 'nil'}" if DEBUG

      puts "[DEBUG] #{count}: ** Start to wait **" if DEBUG
      puts "[DEBUG] #{count}: IO.select(#{hostname_resolution_waiting}, #{connecting_sockets.all}, nil, #{second_to_timeout(now, ends_at)})" if DEBUG
      hostname_resolved, writable_sockets, = IO.select(
        hostname_resolution_waiting,
        connecting_sockets.all,
        nil,
        ends_at ? second_to_timeout(now, ends_at) : nil,
      )
      now = current_clock_time

      puts "[DEBUG] #{count}: ** Check for writable_sockets **" if DEBUG
      puts "[DEBUG] #{count}: writable_sockets #{writable_sockets || 'nil'}" if DEBUG
      puts "[DEBUG] #{count}: connecting_sockets #{connecting_sockets.all}" if DEBUG

      if writable_sockets&.any?
        while (writable_socket = writable_sockets.pop)
          is_connected =
            if is_windows_environment
              sockopt = writable_socket.getsockopt(Socket::SOL_SOCKET, Socket::SO_CONNECT_TIME)
              sockopt.unpack('i').first >= 0
            else
              sockopt = writable_socket.getsockopt(Socket::SOL_SOCKET, Socket::SO_ERROR)
              sockopt.int.zero?
            end

          if is_connected
            puts "[DEBUG] #{count}: Socket for #{writable_socket.remote_address.ip_address} is connected" if DEBUG
            connecting_sockets.delete writable_socket
            return writable_socket
          else
            failed_ai = connecting_sockets.delete writable_socket
            writable_socket.close

            if writable_sockets.any? || resolved_addrinfos.any? || connecting_sockets.any? || !resolved_addrinfos.resolved_all?(resolving_family_names)
              user_specified_connect_timeout_at = nil if connect_timeout && connecting_sockets.empty?
              # Try other writable socket in next "while"
              # Or exit this "while" and try other connection attempt
              # Or exit this "while" and wait for connections to be established or hostname resolution in next loop
              # Or exit this "while" and wait for hostname resolution in next loop
            else
              ip_address = failed_ai.ipv6? ? "[#{failed_ai.ip_address}]" : failed_ai.ip_address
              last_error = SystemCallError.new("connect(2) for #{ip_address}:#{failed_ai.ip_port}", sockopt.int)
              raise last_error
            end
          end
        end
      end

      puts "[DEBUG] #{count}: last error #{last_error&.message|| 'nil'}" if DEBUG

      puts "[DEBUG] #{count}: ** Check for hostname resolution finish **" if DEBUG
      puts "[DEBUG] #{count}: hostname_resolved #{hostname_resolved || 'nil'}" if DEBUG
      if hostname_resolved&.any?
        while (hostname_resolution_result = hostname_resolution_queue.get)
          family_name, result = hostname_resolution_result
          puts "[DEBUG] #{count}: family_name, result #{[family_name, result]}" if DEBUG

          if result.is_a? Exception
            resolved_addrinfos.add(family_name, [])

            unless (Socket.const_defined?(:EAI_ADDRFAMILY)) &&
              (result.is_a?(Socket::ResolutionError)) &&
              (result.error_code == Socket::EAI_ADDRFAMILY)
              last_error = result
            end
          else
            resolved_addrinfos.add(family_name, result)

            if hostname_resolution_queue.empty?
              if resolved_addrinfos.resolved?(:ipv4)
                if resolved_addrinfos.resolved?(:ipv6)
                  puts "[DEBUG] #{count}: All hostname resolution is finished" if DEBUG
                  hostname_resolution_waiting = nil
                  user_specified_resolv_timeout_at = nil
                  user_specified_connect_timeout_at = nil
                else
                  puts "[DEBUG] #{count}: Resolution Delay is ready" if DEBUG
                  resolution_delay_expires_at = now + RESOLUTION_DELAY
                  puts "[DEBUG] #{count}: ends_at #{ends_at}" if DEBUG
                end
              end
            end
          end
        end
      else
        if (expired?(now, user_specified_connect_timeout_at) || expired?(now, user_specified_resolv_timeout_at))
          raise Errno::ETIMEDOUT, 'user specified timeout'
        end
      end

      puts "[DEBUG] #{count}: last error #{last_error&.message|| 'nil'}" if DEBUG

      if resolved_addrinfos.empty? &&
          connecting_sockets.empty? &&
          resolved_addrinfos.resolved_all?(resolving_family_names)
        raise last_error
      end
      puts "------------------------" if DEBUG
    end
  ensure
    hostname_resolution_threads.each do |thread|
      thread.exit
    end

    hostname_resolution_queue&.close_all

    connecting_sockets.each do |connecting_socket|
      connecting_socket.close
    end
  end

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

    ret
  end
  private_class_method :tcp_without_fast_fallback

  def self.ip_address?(hostname)
    hostname.match?(IPV6_ADRESS_FORMAT) || hostname.match?(/^([0-9]{1,3}\.){3}[0-9]{1,3}$/)
  end
  private_class_method :ip_address?

  def self.hostname_resolution(family, host, port, hostname_resolution_queue)
    begin
      resolved_addrinfos = Addrinfo.getaddrinfo(host, port, ADDRESS_FAMILIES[family], :STREAM)
      hostname_resolution_queue.add_resolved(family, resolved_addrinfos)
    rescue => e
      hostname_resolution_queue.add_error(family, e)
    end
  end
  private_class_method :hostname_resolution

  def self.current_clock_time
    Process.clock_gettime(Process::CLOCK_MONOTONIC)
  end
  private_class_method :current_clock_time

  def self.second_to_timeout(started_at, ends_at)
    return 0 if ends_at.nil? || ends_at.zero?

    remaining = (ends_at - started_at)
    remaining.negative? ? 0 : remaining
  end
  private_class_method :second_to_timeout

  def self.expired?(started_at, ends_at)
    return false if ends_at.nil?

    second_to_timeout(started_at, ends_at).zero?
  end
  private_class_method :expired?

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

    def close_all
      @queue.close unless @queue.closed?
      @rpipe.close unless @rpipe.closed?
      @wpipe.close unless @wpipe.closed?
    end

    def empty?
      @queue.empty?
    end
  end
  private_constant :HostnameResolutionQueue

  class ResolvedAddrinfos
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

    def resolved?(family)
      @addrinfo_dict.keys.include? family
    end

    def resolved_all?(families)
      (families - @addrinfo_dict.keys).empty?
    end
  end
  private_constant :ResolvedAddrinfos

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

    def any?
      !empty?
    end

    def each
      @socket_dict.keys.each do |socket|
        yield socket
      end
    end
  end
  private_constant :ConnectingSockets
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
class Addrinfo
  class << self
    alias _getaddrinfo getaddrinfo

    def getaddrinfo(nodename, service, family, *_)
      if service == 9292
        if family == Socket::AF_INET6
          [Addrinfo.tcp("::1", 9292)]
        else
          [Addrinfo.tcp("127.0.0.1", 9292)]
        end
      else
        _getaddrinfo(nodename, service, family)
      end
    end
  end
end

local_ip = Socket.ip_address_list.detect { |addr| addr.ipv4? && !addr.ipv4_loopback? }.ip_address

Socket.tcp(HOSTNAME, PORT, local_ip, 0) do |socket|
   socket.write "GET / HTTP/1.0\r\n\r\n"
   print socket.read
end

# Socket.tcp(HOSTNAME, PORT, fast_fallback: false) do |socket|
#   socket.write "GET / HTTP/1.0\r\n\r\n"
#   print socket.read
# end

# Socket.tcp("127.0.0.1", PORT) do |socket|
#   socket.write "GET / HTTP/1.0\r\n\r\n"
#   print socket.read
# end

# Socket.tcp(HOSTNAME, PORT) do |socket|
#   socket.write "GET / HTTP/1.0\r\n\r\n"
#   print socket.read
# end
