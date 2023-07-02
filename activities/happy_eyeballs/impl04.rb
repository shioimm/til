require 'resolv'
require 'socket'

# アドレス解決
hostname = "localhost"
resolver = Resolv::DNS.new
ipv4_resource = resolver.getresource(hostname, Resolv::DNS::Resource::IN::A)
ipv6_resource = resolver.getresource(hostname, Resolv::DNS::Resource::IN::AAAA)

# 接続試行
class ClientSocket
  attr_reader :sock, :addr

  def initialize(sock, addr)
    @sock = sock
    @addr = addr
  end
end

class ConnectionAttempt
  attr_reader :connecting_starts_at # ConnectionAttemptDelayTimerから参照する

  def initialize
    @clients = {}
    @mutex = Mutex.new
    @connectable = ConditionVariable.new
    @cancelable = ConditionVariable.new
    @connecting_starts_at = nil
  end

  def add_client(client_socket)
    @mutex.synchronize do
      @clients.merge! client_socket
    end
  end

  def attempt(id)
    client = find_client(id)

    @mutex.synchronize do
      @connectable.wait(@mutex) if delaying?

      @connecting_starts_at = Time.now

      result = client.sock.connect(client.addr)

      if result == 0 # 成功
        client.sock.write "GET / HTTP/1.0\r\n\r\n"
        print client.sock.read
        client.sock.close
      end
    end
  end

  def resume
    @connectable.signal
  end

  private

  def find_client(id)
    @clients[id]
  end

  def delaying?
    ConnectionAttemptDelayTimer.delaying?
  end
end

class ConnectionAttemptDelayTimer
  CONNECTION_ATTEMPT_DELAY = 0.25

  def self.delaying?
    # TODO: delayの条件を追加
    false
  end
end

waiting_sockets = []
port = 9292
ipv4_socket = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
ipv4_sockaddr = Socket.sockaddr_in(port, ipv4_resource.address.to_s)
waiting_sockets.push(ClientSocket.new(ipv4_socket, ipv4_sockaddr))

ipv6_socket = Socket.new(Socket::AF_INET6, Socket::SOCK_STREAM, 0)
ipv6_sockaddr = Socket.sockaddr_in(port, ipv6_resource.address.to_s)
waiting_sockets.push(ClientSocket.new(ipv6_socket, ipv6_sockaddr))

WORKING_THREADS = ThreadGroup.new
connection_attempt = ConnectionAttempt.new

while client = waiting_sockets.shift
  t = Thread.start(client) do |client|
    id = rand(10)
    connection_attempt.add_client({ id => client })
    connection_attempt.attempt(id)
  end

  WORKING_THREADS.add t
end

WORKING_THREADS.list.each(&:join)
