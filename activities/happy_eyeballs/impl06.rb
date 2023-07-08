require 'resolv'
require 'socket'

# アドレス解決
class AddressResource
  def initialize
    @addresses = []
    @mutex = Mutex.new
    @cond = ConditionVariable.new
  end

  def add(address)
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

address_resource = AddressResource.new
hostname = "localhost"
resolver = Resolv::DNS.new
type_classes = [Resolv::DNS::Resource::IN::AAAA, Resolv::DNS::Resource::IN::A]

# Producer
type_classes.each do |type|
  address_resource.add Thread.new { resolver.getresource(hostname, type) }.value.address.to_s
end

# 接続試行
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

  def attempt(addrinfo)
    @mutex.synchronize do
      DelayingAttempt.new(self).try_to_attempt if delaying?
      @connectable.wait(@mutex) if delaying?
    end

    ConnectionAttemptDelayTimer.start_timer

    sock = addrinfo.connect
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

waiting_clients = []
port = 9292

# Concumer
type_classes.size.times do # TODO: 暫定条件
  address = address_resource.take # TODO: takeするたびに新しいスレッドを生成し、接続試行する

  family = case address
           when /\w*:+\w*/       then Socket::AF_INET6 # IPv6
           when /\d+.\d+.\d+.\d/ then Socket::AF_INET  # IPv4
           else
             raise StandardError
           end

  sockaddr = Socket.sockaddr_in(port, address)
  addrinfo = Addrinfo.new(sockaddr, family, Socket::SOCK_STREAM, 0)
  waiting_clients.push(addrinfo)
end

WORKING_THREADS = ThreadGroup.new
connection_attempt = ConnectionAttempt.new

while client = waiting_clients.shift # TODO: 暫定処置: 最終的にはConcumerループと統合する
  t = Thread.start(client) do |client|
    connection_attempt.attempt(client)
  end

  WORKING_THREADS.add t
end

WORKING_THREADS.list.each(&:join)
