require 'resolv'
require 'socket'

class Repository
  attr_accessor :collection

  def initialize
    @collection = []
    @mutex = Mutex.new
    @cond = ConditionVariable.new
  end

  def add(resource)
    @mutex.synchronize do
      if resource.is_a? Array
        @collection.push(*resource)
      else
        @collection.push(resource)
      end
      @cond.signal
    end
  end

  def take(timeout = nil)
    @mutex.synchronize do
      @cond.wait(@mutex, timeout) if @collection.empty?
      @collection.shift
    end
  end
end

class ResolutionDelayTimer
  RESOLUTION_DELAY = 0.05

  @mutex = Mutex.new
  @enable = false

  class << self
    def enable?
      @mutex.synchronize do
        @enable
      end
    end

    def enable!
      @mutex.synchronize do
        @enable = true
      end
    end

    def waiting_time
      RESOLUTION_DELAY
    end
  end
end

class HostnameResolution
  def initialize(address_repository)
    @resolver = Resolv::DNS.new
    @address_repository = address_repository
  end

  def get_address_resources!(hostname, type)
    addresses = @resolver.getresources(hostname, type).map { |resource| resource.address.to_s }

    case type
    when Resolv::DNS::Resource::IN::AAAA
      ResolutionDelayTimer.enable!
    when Resolv::DNS::Resource::IN::A
      if ResolutionDelayTimer.enabled?
        sleep ResolutionDelayTimer.waiting_time
      end
    end

    @address_repository.add addresses
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
  def initialize(socket_repository)
    @socket_repository = socket_repository
  end

  def attempt!(addrinfo)
    if (timer = ConnectionAttemptDelayTimer.take_timer) && timer.timein?
      sleep timer.waiting_time
    end

    ConnectionAttemptDelayTimer.start_new_timer
    connected_socket = addrinfo.connect

    # TODO:
    #   サーバに負荷をかけないように@socket_repository.collectionがemptyな場合のみaddした方が良いかも
    #   (その場合はcollectionの参照にロックが必要)
    @socket_repository.add(connected_socket)
  end
end

HOSTNAME = "localhost"
PORT = 9292

# アドレス解決 (Producer)
address_repository = Repository.new
hostname_resolution = HostnameResolution.new(address_repository)

[Resolv::DNS::Resource::IN::AAAA, Resolv::DNS::Resource::IN::A].each do |type|
  Thread.new { hostname_resolution.get_address_resources!(HOSTNAME, type) }
end

# 接続試行 (Consumer)
CONNECTING_THREADS = ThreadGroup.new
socket_repository = Repository.new
connection_attempt = ConnectionAttempt.new(socket_repository)
connected_sockets = []

# RFC8305: Connection Attempts
# the DNS client resolver SHOULD still process DNS replies from the network
# for a short period of time (recommended to be 1 second)
WAITING_DNS_REPLY_SECOND = 1

loop do
  address = address_repository.take(WAITING_DNS_REPLY_SECOND)

  # TODO: この辺りの条件分岐を整理する (connected_socketsを使わずに表現できないか検討)
  if !connected_sockets.empty?
    CONNECTING_THREADS.list.each(&:exit)
    socket_repository.collection.each(&:close)
    break
  elsif connected_sockets.empty? && address.nil?
    connected_socket = socket_repository.take
    connected_sockets.push(connected_socket)
  else
    CONNECTING_THREADS.add (Thread.start(address, socket_repository) { |address, socket_repository|
      family = case address
               when /\w*:+\w*/       then Socket::AF_INET6 # IPv6
               when /\d+.\d+.\d+.\d/ then Socket::AF_INET  # IPv4
               else
                 raise StandardError
               end

      sockaddr = Socket.sockaddr_in(PORT, address)
      addrinfo = Addrinfo.new(sockaddr, family, Socket::SOCK_STREAM, 0)
      connection_attempt.attempt!(addrinfo)
    })
  end
end

CONNECTING_THREADS.list.each(&:join)

sock = connected_sockets.first
sock.write "GET / HTTP/1.0\r\n\r\n"
print sock.read
sock.close
