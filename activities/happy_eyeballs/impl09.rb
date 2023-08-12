require 'socket'

# 追加の作業
#   IO.select後の接続確認
#   AddressResourceStorageに新しいメソッドを追加
#     接続が完了した後にpickした場合は優先的にnilを取得できるようにする必要あり
#     nilを先頭に置くためのメソッドを用意する
#     もしくはAddressResourceStorageをシャットダウンするメソッドと
#     終了状態を確認するメソッドを用意しても良いかも

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

  def resources
    @mutex.synchronize do
      @resources
    end
  end

  def include_ipv6?
    @resources.any?(&:ipv6?)
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

  def take_connected_socket
    connected_socket = @connected_sockets.shift
    @connecting_sockets.delete connected_socket
    connected_socket
  end

  def close_all_sockets!
    @connecting_sockets.each(&:close)
    @connected_sockets.each(&:close)
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
last_attemped_family = nil

# RFC8305: Connection Attempts
# the DNS client resolver SHOULD still process DNS replies from the network
# for a short period of time (recommended to be 1 second)
WAITING_DNS_REPLY_SECOND = 1

connected_socket = loop do
  addrinfo = address_resource_storage.pick(last_attemped_family, timeout: WAITING_DNS_REPLY_SECOND)

  if addrinfo.nil?
    connected_socket = connection_attempt.take_connected_socket
    connection_attempt.close_all_sockets!
    break connected_socket
  end

  last_attemped_family = addrinfo.afamily
  connection_attempt.attempt(addrinfo)

  if !connection_attempt.connected_sockets.empty?
    address_resource_storage.add nil # WAITING_DNS_REPLY_SECONDを待たずに接続試行を終了させる
    next
  end

  # NOTE
  #   IO.selectのtimeoutでConnection Attempt Delayを表現する
  #   タイムアウトした場合は新しいループに入り、次の接続試行を行う
  timer = ConnectionAttemptDelayTimer.take_timer
  _, connected_sockets, = IO.select(nil, connection_attempt.connecting_sockets, nil, timer.waiting_time)

  if connected_sockets && !connected_sockets.empty?
    connection_attempt.connected_sockets.push *connected_sockets
    address_resource_storage.add nil # WAITING_DNS_REPLY_SECONDを待たずに接続試行を終了させる
    next
  end
end

connected_socket.write "GET / HTTP/1.0\r\n\r\n"
print connected_socket.read
connected_socket.close
