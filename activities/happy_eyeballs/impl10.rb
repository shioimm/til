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
    return nil if @ipv6_resource_resolved && @ipv4_resource_resolved

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

  if family == Socket::AF_INET && !address_resource_storage.include_ipv6?
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
      soket.close unless socket.closed?
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
        @last_error = e
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
resolv_timeout = nil # NOTE Socket.tcpにおいてユーザーから渡される可能性あり
address_resource_storage = AddressResourceStorage.new(resolv_timeout)

[:PF_INET6, :PF_INET].each do |family|
  Thread.new { hostname_resolution(HOSTNAME, PORT, family, address_resource_storage) }
end

# 接続試行 (Consumer)
connection_attempt = ConnectionAttempt.new
last_attemped_addrinfo = nil
connect_timeout = nil # TODO ユーザーから渡される引数。ちゃんと時間を測る

connected_socket = loop do
  if connection_attempt.completed?
    connected_socket = connection_attempt.take_connected_socket(last_attemped_addrinfo)
    next unless connected_socket
    connection_attempt.close_all_sockets!
    break connected_socket
  end

  addrinfo = address_resource_storage.pick(last_attemped_addrinfo&.afamily)

  if !addrinfo && !connection_attempt.connecting_sockets.empty?
    # NOTE
    #   アドレス在庫が枯渇しており、接続中のソケットがあるパターン
    #   この接続はtimeoutでユーザーから渡されたconnect_timeoutを表現するためのもの
    #   Socket.tcpにおいてはconnect_timeoutによって待機状態から解除された場合はErrno::ETIMEDOUTを送出する
    #   そうでない場合は永久に待機
    _, connected_sockets, = IO.select(nil, connection_attempt.connecting_sockets, nil, connect_timeout)

    if connected_sockets && !connected_sockets.empty?
      connection_attempt.connected_sockets.push *connected_sockets
      connection_attempt.complete!
      next
    elsif connected_sockets.nil?
      # NOTE connect_timeoutまでに名前解決できなかったパターン
      raise Errno::ETIMEDOUT, 'user specified timeout'
    elsif !connection_attempt.connecting_sockets.empty?
      next
    end
  elsif !addrinfo && connection_attempt.last_error
    # NOTE アドレス在庫が枯渇しており、全てのソケットの接続に失敗しているパターン
    raise connection_attempt.last_error
  elsif !addrinfo
    # NOTE resolv_timeoutまでに名前解決できなかったパターン
    raise Errno::ETIMEDOUT, 'user specified timeout'
  end

  last_attemped_addrinfo = addrinfo
  connection_attempt.attempt(addrinfo)

  if !connection_attempt.connected_sockets.empty?
    connection_attempt.complete!
    next
  end

  if address_resource_storage.out_of_stock? && connection_attempt.connecting_sockets.empty?
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
