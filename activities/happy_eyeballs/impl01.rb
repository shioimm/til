require 'resolv'
require 'socket'

class Client
  attr_accessor :connection_attempt_delaying
  attr_reader :starts_at

  def initialize(sock, addr)
    @sock = sock
    @addr = addr
    @mutex = Mutex.new
    @cond = ConditionVariable.new
    @connection_attempt_delaying = false
  end

  def thread
    @thread ||= Thread.start do
      @mutex.synchronize do
        @cond.wait(@mutex) if connection_attempt_delaying

        result = sock.connect(addr)

        if result == 0 # 成功
          sock.write "GET / HTTP/1.0\r\n\r\n"
          print sock.read
          sock.close
          # TODO: 他の接続スレッドをkillする
        end
      end
    end
  end

  def run
    @cond.signal
  end

  private

  attr_reader :sock, :addr
end

waiting_sockets = []
# TODO: 接続確立後に他の接続スレッドをkillする必要あり。ThreadGroup#list.each(&:kill) など

# アドレス解決
hostname = "localhost"
resolver = Resolv::DNS.new
ipv4_resource = resolver.getresource(hostname, Resolv::DNS::Resource::IN::A)
ipv6_resource = resolver.getresource(hostname, Resolv::DNS::Resource::IN::AAAA)

# 接続試行
port = 9292
ipv4_socket = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
ipv4_sockaddr = Socket.sockaddr_in(port, ipv4_resource.address.to_s)
waiting_sockets.push Client.new(ipv4_socket, ipv4_sockaddr)

ipv6_socket = Socket.new(Socket::AF_INET6, Socket::SOCK_STREAM, 0)
ipv6_sockaddr = Socket.sockaddr_in(port, ipv6_resource.address.to_s)
waiting_sockets.push Client.new(ipv6_socket, ipv6_sockaddr)

class ConnectionAttemptDelayTimer
  CONNECTION_ATTEMPT_DELAY = 0.25

  def initialize(starts_at, client)
    @timeout = starts_at + CONNECTION_ATTEMPT_DELAY
    @client = client
  end

  def count
    loop do
      if Time.now >= @timeout
        @client.connection_attempt_delaying = false
        @client.thread.run
        break
      end

      sleep 0.001
    end
  end
end

waiting_sockets.each_with_index do |client, i|
  t = client.thread

  if (next_client = waiting_sockets[i + 1])
    next_client.connection_attempt_delaying = true
    ConnectionAttemptDelayTimer.new(Time.now, next_client).count
  end

  t.join
end
