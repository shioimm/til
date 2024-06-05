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

  IPV6_ADRESS_FORMAT = /(?i)(?:(?:[0-9A-F]{1,4}:){7}(?:[0-9A-F]{1,4}|:)|(?:[0-9A-F]{1,4}:){6}(?:[0-9A-F]{1,4}::[0-9A-F]{1,4}|:(?:[0-9A-F]{1,4}:){1,5}[0-9A-F]{1,4}|:)|(?:[0-9A-F]{1,4}:){5}(?::[0-9A-F]{1,4}::[0-9A-F]{1,4}|:(?:[0-9A-F]{1,4}:){1,4}[0-9A-F]{1,4}|:)|(?:[0-9A-F]{1,4}:){4}(?::[0-9A-F]{1,4}::[0-9A-F]{1,4}|:(?:[0-9A-F]{1,4}:){1,3}[0-9A-F]{1,4}|:)|(?:[0-9A-F]{1,4}:){3}(?::[0-9A-F]{1,4}::[0-9A-F]{1,4}|:(?:[0-9A-F]{1,4}:){1,2}[0-9A-F]{1,4}|:)|(?:[0-9A-F]{1,4}:){2}(?::[0-9A-F]{1,4}::[0-9A-F]{1,4}|:(?:[0-9A-F]{1,4}:)[0-9A-F]{1,4}|:)|(?:[0-9A-F]{1,4}:){1}(?::[0-9A-F]{1,4}::[0-9A-F]{1,4}|::(?:[0-9A-F]{1,4}:){1,5}[0-9A-F]{1,4}|:)|::(?:[0-9A-F]{1,4}::[0-9A-F]{1,4}|:(?:[0-9A-F]{1,4}:){1,6}[0-9A-F]{1,4}|:))(?:%.+)?/
  private_constant :IPV6_ADRESS_FORMAT

  @tcp_fast_fallback = true

  class << self
    attr_accessor :tcp_fast_fallback
  end

  def self.tcp(host, port, local_host = nil, local_port = nil, connect_timeout: nil, resolv_timeout: nil, fast_fallback: tcp_fast_fallback, &block) # :yield: socket
   use_hev2 = fast_fallback && !(host && connecting_to_ip_address?(host))

    if !use_hev2
      return tcp_without_fast_fallback(host, port, local_host, local_port, connect_timeout:, resolv_timeout:, &block)
    end

    resolving_family_names = ADDRESS_FAMILIES.keys
    hostname_resolution_threads = []
    hostname_resolution_queue = HostnameResolutionQueue.new(resolving_family_names.size)
    hostname_resolution_waiting = hostname_resolution_queue.waiting_pipe
    resolved_addrinfos = ResolvedAddrinfos.new
    connecting_sockets = ConnectingSockets.new
    connected_socket = nil
    is_windows_environment ||= (RUBY_PLATFORM =~ /mswin|mingw|cygwin/)

    if local_host && local_port
      # TODO
    end

    hostname_resolution_args = [host, port, hostname_resolution_queue]

    hostname_resolution_threads.concat(
      resolving_family_names.map { |family|
        thread_args = [family, *hostname_resolution_args]
        thread = Thread.new(*thread_args) { |*thread_args| hostname_resolution(*thread_args) }
        Thread.pass
        thread
      }
    )

    ends_at = nil
    count = 0 # for debugging

    ret = loop do
      count += 1 # for debugging

      puts "[DEBUG] #{count}: ** Start to wait **"
      puts "[DEBUG] #{count}: IO.select(#{hostname_resolution_waiting}, #{connecting_sockets.all}, nil, #{second_to_timeout(ends_at)})"
      hostname_resolved, writable_sockets, = IO.select(
        hostname_resolution_waiting,
        connecting_sockets.all,
        nil,
        ends_at ? second_to_timeout(ends_at) : nil,
      )
      ends_at = nil

      puts "[DEBUG] #{count}: ** Check for writable_sockets **"
      puts "[DEBUG] #{count}: writable_sockets #{writable_sockets}"
      puts "[DEBUG] #{count}: connecting_sockets #{connecting_sockets.all}"

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
            puts "[DEBUG] #{count}: Socket for #{writable_socket.remote_address.ip_address} is connected"
            connected_socket = writable_socket
            connecting_sockets.delete connected_socket
            writable_sockets.each do |other_writable_socket|
              other_writable_socket.close unless other_writable_socket.closed?
            end
            break
          else
            failed_ai = connecting_sockets.delete writable_socket
            inspected_ip_address = failed_ai.ipv6? ? "[#{failed_ai.ip_address}]" : failed_ai.ip_address
            last_error = SystemCallError.new("connect(2) for #{inspected_ip_address}:#{failed_ai.ip_port}", sockopt.int)
            writable_socket.close unless writable_socket.closed?
          end
        end
      end

      break connected_socket if connected_socket

      puts "[DEBUG] #{count}: ** Check for hostname resolution finish **"
      puts "[DEBUG] #{count}: hostname_resolved #{hostname_resolved}"
      if hostname_resolved&.any?
        family_name, res = hostname_resolution_queue.get
        puts "[DEBUG] #{count}: family_name, res #{[family_name, res]}"

        if res.is_a? Exception
          unless (Socket.const_defined?(:EAI_ADDRFAMILY)) &&
            (res.is_a?(Socket::ResolutionError)) &&
            (res.error_code == Socket::EAI_ADDRFAMILY)
            last_error = res
          end
        else
          resolved_addrinfos.add(family_name, res)

          if family_name.eql?(:ipv4) && !resolved_addrinfos.resolved?(:ipv6)
            ends_at = now + RESOLUTION_DELAY
          end
        end

        # TODO Queueでよいかどうかも含めてちょっと考える
        hostname_resolution_waiting = hostname_resolution_waiting && hostname_resolution_queue.closed? ?
          nil :
          hostname_resolution_waiting
      end

      if second_to_timeout(ends_at).zero? && resolved_addrinfos.any?
        puts "[DEBUG] #{count}: ** Start to connect **"
        puts "[DEBUG] #{count}: resolved_addrinfos #{resolved_addrinfos.instance_variable_get(:"@addrinfo_dict")}"
        # TODO local_host / local_portがある場合

        while (addrinfo = resolved_addrinfos.get)
          puts "[DEBUG] #{count}: Start to connect to #{addrinfo.ip_address}"

          begin
            socket = Socket.new(addrinfo.pfamily, addrinfo.socktype, addrinfo.protocol)
            # TODO socket.bind(local_addrinfo) if local_addrinfo
            result = socket.connect_nonblock(addrinfo, exception: false)
            ends_at = now + CONNECTION_ATTEMPT_DELAY

            case result
            when 0
              connected_socket = socket
              break
            when :wait_writable # 接続試行中
              connecting_sockets.add(socket, addrinfo)
              break
            end
          rescue SystemCallError => e
            last_error = $!
            next
          end
        end
      end
      puts "[DEBUG] #{count}: connecting_sockets #{connecting_sockets.all}"

      if !connected_socket &&
          resolved_addrinfos.empty? &&
          connecting_sockets.empty? &&
          hostname_resolution_queue.closed?
        raise last_error
      end
      puts "------------------------"
    end

    puts "[DEBUG] ret.remote_address #{ret.remote_address.ip_address}"
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
    if use_hev2
      hostname_resolution_threads.each do |thread|
        thread&.exit
      end

      hostname_resolution_queue&.close_all

      connecting_sockets.each do |connecting_socket|
        connecting_socket.close unless connecting_socket.closed?
      end
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

  def self.connecting_to_ip_address?(hostname)
    hostname.match?(IPV6_ADRESS_FORMAT) || hostname.match?(/^([0-9]{1,3}\.){3}[0-9]{1,3}$/)
  end
  private_class_method :connecting_to_ip_address?

  def self.hostname_resolution(family, host, port, hostname_resolution_queue)
    begin
      resolved_addrinfos = Addrinfo.getaddrinfo(host, port, ADDRESS_FAMILIES[family], :STREAM)
      hostname_resolution_queue.add_resolved(family, resolved_addrinfos)
    rescue => e
      hostname_resolution_queue.add_error(family, e)
    end
  end
  private_class_method :hostname_resolution

  def self.now
    Process.clock_gettime(Process::CLOCK_MONOTONIC)
  end
  private_class_method :now

  def self.second_to_timeout(ends_at)
    return 0 unless ends_at

    remaining = (ends_at - now)
    remaining.negative? ? 0 : remaining
  end
  private_class_method :second_to_timeout

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

    def opened?
      !closed?
    end

    def close_all
      @queue.close unless @queue.closed?
      @rpipe.close unless @rpipe.closed?
      @wpipe.close unless @wpipe.closed?
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
#
# Socket.tcp(HOSTNAME, PORT, fast_fallback: false) do |socket|
#   socket.write "GET / HTTP/1.0\r\n\r\n"
#   print socket.read
# end
#
# Socket.tcp("127.0.0.1", PORT) do |socket|
#   socket.write "GET / HTTP/1.0\r\n\r\n"
#   print socket.read
# end

# Socket.tcp(HOSTNAME, PORT) do |socket|
#   socket.write "GET / HTTP/1.0\r\n\r\n"
#   print socket.read
# end
