require 'resolv'
require 'socket'

HOSTNAME = "localhost"
PORT = 9292

# アドレス解決
class AddressResource
  # RFC8305: Connection Attempts
  # the DNS client resolver SHOULD still process DNS replies from the network
  # for a short period of time (recommended to be 1 second)
  WAITING_DNS_REPLY_SECOND = 1

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
      @cond.wait(@mutex, WAITING_DNS_REPLY_SECOND) if @addresses.size <= 0
      @addresses.shift
    end
  end
end

address_resource = AddressResource.new
resolver = Resolv::DNS.new
type_classes = [Resolv::DNS::Resource::IN::AAAA, Resolv::DNS::Resource::IN::A]

# Producer
type_classes.each do |type|
  # TODO: Resolution Delayの実装を追加する
  address_resource.add Thread.new { resolver.getresource(HOSTNAME, type) }.value.address.to_s
end

# 接続試行
class ConnectionAttempt
  def attempt(addrinfo)
    if (timer = ConnectionAttemptDelayTimer.take_timer) && timer.timein?
      sleep timer.waiting_time
    end

    ConnectionAttemptDelayTimer.start_new_timer

    sock = addrinfo.connect
    sock.write "GET / HTTP/1.0\r\n\r\n"
    print sock.read
    sock.close

    (CONNECTING_THREADS.list - [Thread.current]).each(&:kill)
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

CONNECTING_THREADS = ThreadGroup.new
connection_attempt = ConnectionAttempt.new

# Concumer
loop do
  address = address_resource.take

  break if address.nil?

  family = case address
           when /\w*:+\w*/       then Socket::AF_INET6 # IPv6
           when /\d+.\d+.\d+.\d/ then Socket::AF_INET  # IPv4
           else
             raise StandardError
           end

  sockaddr = Socket.sockaddr_in(PORT, address)
  addrinfo = Addrinfo.new(sockaddr, family, Socket::SOCK_STREAM, 0)

  t = Thread.start(addrinfo) do |addrinfo|
    connection_attempt.attempt(addrinfo)
  end

  CONNECTING_THREADS.add t
end

CONNECTING_THREADS.list.each(&:join)
