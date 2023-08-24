require 'socket'

class AddressResourceStorage
  def initialize(resolv_timeout = nil)
    @resources = []
    @mutex = Mutex.new
    @cond = ConditionVariable.new
    @resolv_timeout = resolv_timeout
    @ipv6_resource_resolved = false
    @ipv4_resource_resolved = false
  end

  def add(resources)
    # NOTE
    #   現状ではアドレスファミリごとにAddrinfo.getaddrinfoが呼ばれる実装なのでこれでも動作する
    #   アドレスファミリによらずアドレスを一つずつ非同期に取得する方法で取得するような場合は修正が必要
    case resources.first.afamily
    when Socket::AF_INET6 then @ipv6_resource_resolved = true
    when Socket::AF_INET  then @ipv4_resource_resolved = true
    end

    @mutex.synchronize do
      @resources.push(*resources)
      @cond.signal
    end
  end

  def pick(last_family = nil)
    return nil if @ipv6_resource_resolved && @ipv4_resource_resolved && @resources.empty?

    @mutex.synchronize do
      @cond.wait(@mutex, @resolv_timeout) if @resources.empty?

      if last_family && (addrinfo = @resources.find { |addrinfo| !addrinfo.afamily == last_family })
        @resources.delete addrinfo
      else
        @resources.shift
      end
    end
  end

  def include_ipv6?
    @resources.any?(&:ipv6?)
  end

  def out_of_stock?
    @resources.empty?
  end
end

RESOLUTION_DELAY = 0.05

def hostname_resolution(hostname, port, family, address_resource_storage)
  resources = Addrinfo.getaddrinfo(hostname, port, family, :STREAM)

  if family == :PF_INET && !address_resource_storage.include_ipv6?
    sleep RESOLUTION_DELAY
  end

  address_resource_storage.add resources
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

  def initialize
    @connected_sockets = []
    @connecting_sockets = []
    @completed = false
  end

  def attempt(addrinfo)
    return if !@connected_sockets.empty?

    socket = Socket.new(addrinfo.pfamily, addrinfo.socktype, addrinfo.protocol)
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

# TODO
#   local_host / local_portを考慮する
#   ブロックを実行できるようにする
#   アドレス解決のスレッドを終了させる
#   AddressResourceStorageをQueueのサブクラスにできないか検討

class Socket
  def self.tcp(host, port, local_host = nil, local_port = nil, resolv_timeout: nil, connect_timeout: nil)
    # アドレス解決 (Producer)
    address_resource_storage = AddressResourceStorage.new(resolv_timeout)

    [:PF_INET6, :PF_INET].each do |family|
      Thread.new { hostname_resolution(host, port, family, address_resource_storage) }
    end

    # 接続試行 (Consumer)
    started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    connection_attempt = ConnectionAttempt.new
    last_attemped_addrinfo = nil

    ret = loop do
      if connection_attempt.completed?
        connected_socket = connection_attempt.take_connected_socket(last_attemped_addrinfo)

        if connected_socket.nil? && connection_attempt.last_error
          raise connection_attempt.last_error if address_resource_storage.out_of_stock?

          connection_attempt.incomplete!
          next
        end

        connection_attempt.close_all_sockets!
        break connected_socket
      end

      addrinfo = address_resource_storage.pick(last_attemped_addrinfo&.afamily)

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

      if connection_attempt.last_error && !address_resource_storage.out_of_stock?
        next
      end

      if !connection_attempt.connected_sockets.empty?
        connection_attempt.complete!
        next
      end

      if address_resource_storage.out_of_stock? && connection_attempt.connecting_sockets.empty?
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

    ret
  end
end

# # HOSTNAME = "www.google.com"
# # PORT = 80
# HOSTNAME = "localhost"
# PORT = 9292
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
# connected_socket = Socket.tcp(HOSTNAME, PORT)
# connected_socket.write "GET / HTTP/1.0\r\n\r\n"
# print connected_socket.read
# connected_socket.close
