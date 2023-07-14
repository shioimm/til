require 'resolv'
require 'socket'

# TODO:
#   AddressResourceを汎用的にリソースを扱えるようなクラスにする
#   #add_connected_socketと#take_connected_socketは削除
#   WAITING_DNS_REPLY_SECONDは引数として渡す
class AddressResource
  # RFC8305: Connection Attempts
  # the DNS client resolver SHOULD still process DNS replies from the network
  # for a short period of time (recommended to be 1 second)
  WAITING_DNS_REPLY_SECOND = 1

  def initialize
    @addresses = []
    @connected_socket = nil
    @mutex = Mutex.new
    @cond = ConditionVariable.new
  end

  def add(addresses)
    @mutex.synchronize do
      @addresses.push(*addresses)
      @cond.signal
    end
  end

  def take
    @mutex.synchronize do
      @cond.wait(@mutex, WAITING_DNS_REPLY_SECOND) if @addresses.empty?
      @addresses.shift
    end
  end

  def add_connected_socket(socket)
    @mutex.synchronize do
      @connected_socket = socket
      @cond.signal
    end
  end

  def take_connected_socket
    @mutex.synchronize do
      @cond.wait(@mutex) if @connected_socket.nil?
      @connected_socket
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
  def initialize(address_resource)
    @resolver = Resolv::DNS.new
    @address_resource = address_resource
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

    @address_resource.add addresses
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
  def attempt(addrinfo)
    if (timer = ConnectionAttemptDelayTimer.take_timer) && timer.timein?
      sleep timer.waiting_time
    end

    ConnectionAttemptDelayTimer.start_new_timer
    addrinfo.connect
  end
end

HOSTNAME = "localhost"
PORT = 9292

# アドレス解決 (Producer)
address_resource = AddressResource.new
hostname_resolution = HostnameResolution.new(address_resource)

[Resolv::DNS::Resource::IN::AAAA, Resolv::DNS::Resource::IN::A].each do |type|
  Thread.new { hostname_resolution.get_address_resources!(HOSTNAME, type) }
end

# 接続試行 (Consumer)
CONNECTING_THREADS = ThreadGroup.new
MUTEX = Mutex.new
COND = ConditionVariable.new
connection_attempt = ConnectionAttempt.new
connected_sockets = []

loop do
  address = address_resource.take

  if !connected_sockets.empty?
    # TODO: 接続ソケットのうち、実際に書き込むソケット以外はcloseする
    CONNECTING_THREADS.list.each(&:kill)
    break
  elsif connected_sockets.empty? && address.nil?
    # TODO: ここはもう少しきれいにしたい
    connected_sockets << address_resource.take_connected_socket
  else
    CONNECTING_THREADS.add (Thread.start(address, address_resource) { |address, address_resource|
      family = case address
               when /\w*:+\w*/       then Socket::AF_INET6 # IPv6
               when /\d+.\d+.\d+.\d/ then Socket::AF_INET  # IPv4
               else
                 raise StandardError
               end

      sockaddr = Socket.sockaddr_in(PORT, address)
      addrinfo = Addrinfo.new(sockaddr, family, Socket::SOCK_STREAM, 0)
      address_resource.add_connected_socket connection_attempt.attempt(addrinfo)
    })
  end
end

CONNECTING_THREADS.list.each(&:join)

sock = connected_sockets.first
sock.write "GET / HTTP/1.0\r\n\r\n"
print sock.read
sock.close
