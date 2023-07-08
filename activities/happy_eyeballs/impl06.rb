require 'resolv'
require 'socket'

class ClientAddrinfo
  attr_reader :addrinfo

  def initialize(addrinfo)
    @addrinfo = addrinfo
  end
end

class ConnectionAttempt
  class DelayingAttempt
    def initialize(attempt)
      @attempt = attempt
    end

    def try_to_attempt
      loop do
        if !ConnectionAttemptDelayTimer.delaying?
          @attempt.resume
          ConnectionAttemptDelayTimer.update
          break
        end

        sleep 0.001
      end
    end
  end

  def initialize
    @mutex = Mutex.new
    @connectable = ConditionVariable.new
    @connecting_starts_at = nil
  end

  def attempt(client)
    @mutex.synchronize do
      DelayingAttempt.new(self).try_to_attempt if delaying?
      @connectable.wait(@mutex) if delaying?
    end

    ConnectionAttemptDelayTimer.start_timer

    sock = client.addrinfo.connect
    sock.write "GET / HTTP/1.0\r\n\r\n"
    print sock.read
    sock.close

    (WORKING_THREADS.list - [Thread.current]).each(&:kill)
  end

  def resume
    @connectable.signal
  end

  private

  def delaying?
    ConnectionAttemptDelayTimer.delaying?
  end
end

class ConnectionAttemptDelayTimer
  CONNECTION_ATTEMPT_DELAY = 0.25

  @mutex = Mutex.new
  @timers = []

  class << self
    def delaying?
      !@timers.empty? && !timeout?
    end

    def start_timer
      @mutex.synchronize do
        @timers << self.new
      end
    end

    def update
      @mutex.synchronize do
        @timers.delete_at 0
      end
    end

    private

    def timeout?
      Time.now > @timers.first.connecting_starts_at + CONNECTION_ATTEMPT_DELAY
    end
  end

  attr_reader :connecting_starts_at

  def initialize
    @connecting_starts_at = Time.now
  end
end

# アドレス解決
hostname = "localhost"
resolver = Resolv::DNS.new
type_classes = [Resolv::DNS::Resource::IN::AAAA, Resolv::DNS::Resource::IN::A]

class AddressStorage
  def initialize
    @addresses = []
    @mutex = Mutex.new
    @cond = ConditionVariable.new
  end

  def append(address)
    @mutex.synchronize do
      @addresses.push address
      @cond.signal
    end
  end

  def take # TODO: consumerがtakeを中断するための処理を追加する
    @mutex.synchronize do
      while @addresses.size <= 0
        @cond.wait(@mutex)
      end

      @addresses.shift
    end
  end
end

address_storage = AddressStorage.new

type_classes.each do |type|
  address_storage.append Thread.new { resolver.getresource(hostname, type) }.value.address.to_s
end

# 接続試行
addresses = []
waiting_clients = []
port = 9292

type_classes.size.times do # TODO: 暫定条件
  addresses << address_storage.take # TODO: takeするたびに新しいスレッドを生成し、接続試行する
end

ipv6_addr, ipv4_addr = addresses

ipv4_sockaddr = Socket.sockaddr_in(port, ipv4_addr)
ipv4_addrinfo = Addrinfo.new(ipv4_sockaddr, Socket::AF_INET, Socket::SOCK_STREAM, 0)
waiting_clients.push(ClientAddrinfo.new(ipv4_addrinfo))

ipv6_sockaddr = Socket.sockaddr_in(port, ipv6_addr)
ipv6_addrinfo = Addrinfo.new(ipv6_sockaddr, Socket::AF_INET6, Socket::SOCK_STREAM, 0)
waiting_clients.push(ClientAddrinfo.new(ipv6_addrinfo))

WORKING_THREADS = ThreadGroup.new
connection_attempt = ConnectionAttempt.new

while client = waiting_clients.shift
  t = Thread.start(client) do |client|
    connection_attempt.attempt(client)
  end

  WORKING_THREADS.add t
end

WORKING_THREADS.list.each(&:join)
