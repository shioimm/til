require 'socket'

# ここまでの実装:
#   変更:
#     接続試行をノンブロッキングモードで行うようにした
#       アドレスの在庫が枯渇した後、接続中のソケットが残っている場合は接続確立を待機するようにした
#     Connection Attempt DelayをIO.selectのtimeoutで行うようにした
#   機能追加:
#     AddressResourceStorage#out_of_stock?
#     ConnectionAttempt#completed
#     ConnectionAttempt#connecting_sockets
#     ConnectionAttempt#connected_sockets
#     ConnectionAttempt#take_connected_socket
#     ConnectionAttempt#close_all_sockets
#   機能削除:
#     AddressResourceStorage#resources (使ってなかった)

class AddressResourceStorage
  def initialize
    @resources = []
    @mutex = Mutex.new
    @cond = ConditionVariable.new
  end

  def add(resource)
    @mutex.synchronize do
      @resources.push(*resource)
      @cond.signal
    end
  end

  def pick(last_family = nil, timeout: nil)
    @mutex.synchronize do
      @cond.wait(@mutex, timeout) if @resources.empty?

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

class HostnameResolution
  RESOLUTION_DELAY = 0.05

  def initialize(address_resource_storage)
    @address_resource_storage = address_resource_storage
  end

  def get_address_resources!(hostname, port, family)
    resources = Addrinfo.getaddrinfo(hostname, port, family, :STREAM)

    if family == :PF_INET4 && !@address_resource_storage.include_ipv6?
      sleep RESOLUTION_DELAY
    end

    @address_resource_storage.add resources
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
  attr_reader :connected_sockets, :connecting_sockets

  def initialize
    @connected_sockets = []
    @connecting_sockets = []
    @completed = false
  end

  def attempt(addrinfo)
    return if !@connected_sockets.empty?

    socket = Socket.new(addrinfo.pfamily, addrinfo.socktype, addrinfo.protocol)
    ConnectionAttemptDelayTimer.start_new_timer

    case socket.connect_nonblock(addrinfo, exception: false)
    when 0              then @connected_sockets.push socket
    when :wait_writable then @connecting_sockets.push socket
    end
  end

  def take_connected_socket(addrinfo)
    @connected_sockets.find do |socket|
      begin
        socket.connect_nonblock(addrinfo)
        true
      rescue Errno::EISCONN # already connected
        @connected_sockets.delete socket
        @connecting_sockets.delete socket
        true
      rescue => e
        socket.close unless socket.closed?
        false
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

  def completed?
    @completed
  end
end

HOSTNAME = "localhost"
PORT = 9292

# アドレス解決 (Producer)
address_resource_storage = AddressResourceStorage.new
hostname_resolution = HostnameResolution.new(address_resource_storage)

[:PF_INET6, :PF_INET].each do |family|
  Thread.new { hostname_resolution.get_address_resources!(HOSTNAME, PORT, family) }
end

# 接続試行 (Consumer)
connection_attempt = ConnectionAttempt.new
last_attemped_addrinfo = nil

# RFC8305: Connection Attempts
# the DNS client resolver SHOULD still process DNS replies from the network
# for a short period of time (recommended to be 1 second)
WAITING_DNS_REPLY_SECOND = 1

connected_socket = loop do
  if connection_attempt.completed?
    connected_socket = connection_attempt.take_connected_socket(last_attemped_addrinfo)
    next unless connected_socket
    connection_attempt.close_all_sockets!
    break connected_socket
  end

  addrinfo = address_resource_storage.pick(last_attemped_addrinfo&.afamily, timeout: WAITING_DNS_REPLY_SECOND)

  if !addrinfo && !connection_attempt.connecting_sockets.empty?
    # NOTE
    #   このIO.selectはアドレス在庫が枯渇しており、接続中のソケットがある場合に接続を待機するためのもの
    #   なおSocket.tcpにおいて、connect_timeoutがある場合はErrno::ETIMEDOUTを送出する
    #   そうでない場合は永久に待機
    _, connected_sockets, = IO.select(nil, connection_attempt.connecting_sockets)

    if connected_sockets && !connected_sockets.empty?
      connection_attempt.connected_sockets.push *connected_sockets
      connection_attempt.complete!
      next
    elsif !connection_attempt.connecting_sockets.empty?
      next
    end
  end

  last_attemped_addrinfo = addrinfo
  connection_attempt.attempt(addrinfo)

  if !connection_attempt.connected_sockets.empty?
    connection_attempt.complete!
    next
  end

  if address_resource_storage.out_of_stock? &&connection_attempt.connecting_sockets.empty?
    next
  end

  # NOTE
  #   このIO.selectはtimeoutでConnection Attempt Delayを表現するためのもの
  #   タイムアウトした場合は新しいループに入り、次の接続試行を行う
  timer = ConnectionAttemptDelayTimer.take_timer
  _, connected_sockets, = IO.select(nil, connection_attempt.connecting_sockets, nil, timer.waiting_time)

  if connected_sockets && !connected_sockets.empty?
    connection_attempt.connected_sockets.push *connected_sockets
    connection_attempt.complete!
    next
  end
end

connected_socket.write "GET / HTTP/1.0\r\n\r\n"
print connected_socket.read
connected_socket.close
