require 'socket'

RESOLUTION_DELAY = 0.05

def hostname_resolution(hostname, port, family, pickable_addrinfos, mutex, cond)
  resolved_addrinfos = Addrinfo.getaddrinfo(hostname, port, family, :STREAM)

  if family == :PF_INET && !pickable_addrinfos.any?(&:ipv6?)
    sleep RESOLUTION_DELAY
  end

  mutex.synchronize do
    pickable_addrinfos.push *resolved_addrinfos
    cond.signal
  end
end

def pick_addrinfo(pickable_addrinfos, last_family, resolv_timeout, mutex, cond)
  mutex.synchronize do
    cond.wait(mutex, resolv_timeout) if pickable_addrinfos.empty?

    if last_family && (addrinfo = pickable_addrinfos.find { |addrinfo| !addrinfo.afamily == last_family })
      pickable_addrinfos.delete addrinfo
    else
      pickable_addrinfos.shift
    end
  end
end

class ConnectionAttemptDelayTimer
  CONNECTION_ATTEMPT_DELAY = 0.25

  @mutex = Mutex.new
  @timers = []

  class << self
    def start_new_timer
      @mutex.synchronize do
        @timers << self.new
      end
    end

    def take_timer
      @mutex.synchronize do
        @timers.shift
      end
    end
  end

  def initialize
    @starts_at = Time.now
    @ends_at = @starts_at + CONNECTION_ATTEMPT_DELAY
  end

  def timein?
    @ends_at > Time.now
  end

  def waiting_time
    @ends_at - Time.now
  end
end

class ConnectionAttempt
  attr_reader :connected_sockets, :connecting_sockets, :last_error

  def initialize(local_addresses = [])
    @local_addresses = local_addresses
    @connected_sockets = []
    @connecting_sockets = []
    @completed = false
  end

  def attempt(addrinfo)
    return if !@connected_sockets.empty?

    socket = Socket.new(addrinfo.pfamily, addrinfo.socktype, addrinfo.protocol)

    if !@local_addresses.empty?
      local_address = @local_addresses.find { |local_ai| local_ai.afamily == addrinfo.afamily }
      socket.bind(local_address) if local_address
    end

    ConnectionAttemptDelayTimer.start_new_timer

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

  def complete!
    @completed = true
  end

  def incomplete!
    @completed = false
  end

  def completed?
    @completed
  end
end

def second_to_timeout(started_at, waiting_time)
  return if waiting_time.nil?

  elapsed_time = Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at
  timeout = waiting_time - elapsed_time
  timeout.negative? ? 0 : timeout
end

class Socket
  def self.tcp(host, port, local_host = nil, local_port = nil, resolv_timeout: nil, connect_timeout: nil)
    mutex = Mutex.new
    cond = ConditionVariable.new

    # アドレス解決 (Producer)
    local_addresses = []
    hostname_resolving_families = [:PF_INET6, :PF_INET]
    pickable_addrinfos = []
    ipv6_picked = false
    ipv4_picked = false

    if !local_host.nil? || !local_port.nil?
      hostname_resolving_families = []
      local_addresses = Addrinfo.getaddrinfo(local_host, local_port, nil, :STREAM, nil)

      [Socket::AF_INET6, Socket::AF_INET].each do |family|
        if local_addresses.any? { |local_ai| local_ai.pfamily === family }
          hostname_resolving_families.push (family == Socket::AF_INET6 ? :PF_INET6 : :PF_INET)
        end
      end
    end

    hostname_resolution_threads = hostname_resolving_families.map do |family|
      Thread.new { hostname_resolution(host, port, family, pickable_addrinfos, mutex, cond) }
    end

    # 接続試行 (Consumer)
    started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    connection_attempt = ConnectionAttempt.new(local_addresses)
    last_attemped_addrinfo = nil

    ret = loop do
      if connection_attempt.completed?
        connected_socket = connection_attempt.take_connected_socket(last_attemped_addrinfo)

        if connected_socket.nil? && connection_attempt.last_error
          raise connection_attempt.last_error if pickable_addrinfos.empty?

          connection_attempt.incomplete!
          next
        end

        connection_attempt.close_all_sockets!
        break connected_socket
      end

      addrinfo =
        if ipv6_picked && ipv4_picked && pickable_addrinfos.empty?
          nil
        else
          pick_addrinfo(pickable_addrinfos, last_attemped_addrinfo&.afamily, resolv_timeout, mutex, cond)
        end

      ipv6_picked = true if !ipv6_picked && addrinfo&.ipv6?
      ipv4_picked = true if !ipv4_picked && addrinfo&.ipv4?

      if !addrinfo && !connection_attempt.connecting_sockets.empty?
        # アドレス在庫が枯渇しており、接続中のソケットがある場合
        to_timeout = second_to_timeout(started_at, connect_timeout)
        _, connected_sockets, = IO.select(nil, connection_attempt.connecting_sockets, nil, to_timeout)

        if connected_sockets && !connected_sockets.empty?
          # connect_timeout終了前に接続できたソケットがある場合
          connection_attempt.connected_sockets.push *connected_sockets
          connection_attempt.complete!
          next
        elsif connected_sockets.nil?
          # connect_timeoutまでに名前解決できなかった場合
          raise Errno::ETIMEDOUT, 'user specified timeout'
        end
      elsif !addrinfo && connection_attempt.last_error
        # アドレス在庫が枯渇しており、全てのソケットの接続に失敗している場合
        raise connection_attempt.last_error
      elsif !addrinfo
        # Resolve Timeout
        raise Errno::ETIMEDOUT, 'user specified timeout'
      end

      last_attemped_addrinfo = addrinfo
      connection_attempt.attempt(addrinfo)

      if connection_attempt.last_error && !pickable_addrinfos.empty?
        next
      end

      if !connection_attempt.connected_sockets.empty?
        connection_attempt.complete!
        next
      end

      if pickable_addrinfos.empty? && connection_attempt.connecting_sockets.empty?
        next
      end

      timer = ConnectionAttemptDelayTimer.take_timer
      _, connected_sockets, = IO.select(nil, connection_attempt.connecting_sockets, nil, timer.waiting_time)

      if connected_sockets && !connected_sockets.empty?
        connection_attempt.connected_sockets.push *connected_sockets
        connection_attempt.complete!
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
