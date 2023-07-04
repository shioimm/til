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

addresses = []
# 値が入るのを監視する必要あり。配列ではなく専用のクラスを用意してwaiting_clientsと合流させた方がいいかも

# TODO: 一旦スレッドでアドレス解決を行うようにしただけ
type_classes.each do |type|
  addresses << Thread.new { resolver.getresource(hostname, type) }.value.address.to_s
end
# addressesに値が入るのを待って条件に応じて接続 or 待機
#   フルリゾルバから最初に有効なAAAA応答を受信した場合、クライアントは最初のIPv6接続を直ちに試行する
#   フルリゾルバから最初に有効なA応答を受信した場合、50ms待つ
# Resolution DelayとClientAddrinfoをつくる処理をどこで行うべきか

# 接続試行
waiting_clients = []
port = 9292
ipv6_addr, ipv4_addr = addresses
# Addrinfo.newする際の処理を共通化するにはこの文字列がIPv6なのかIPv4なのかを判断する必要があるのでは

ipv4_sockaddr = Socket.sockaddr_in(port, ipv4_addr)
ipv4_addrinfo = Addrinfo.new(ipv4_sockaddr, Socket::AF_INET, Socket::SOCK_STREAM, 0)
waiting_clients.push(ClientAddrinfo.new(ipv4_addrinfo))

ipv6_sockaddr = Socket.sockaddr_in(port, ipv6_addr)
ipv6_addrinfo = Addrinfo.new(ipv6_sockaddr, Socket::AF_INET6, Socket::SOCK_STREAM, 0)
waiting_clients.push(ClientAddrinfo.new(ipv6_addrinfo))

WORKING_THREADS = ThreadGroup.new
connection_attempt = ConnectionAttempt.new

# whileする単位をtype_classesにした方が良いかも?
while client = waiting_clients.shift
  t = Thread.start(client) do |client|
    connection_attempt.attempt(client)
  end

  WORKING_THREADS.add t
end

WORKING_THREADS.list.each(&:join)
