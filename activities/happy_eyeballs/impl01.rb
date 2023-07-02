require 'resolv'
require 'socket'

# ここまでの実装:
#   アドレス解決 -> 同期的に実行
#   接続試行     -> 実装済み、ConnectionAttemptDelayTimer周りの実装がもっさりしている

WAITING_SOCKETS = []
WORKING_THREADS = ThreadGroup.new

class Client
  attr_accessor :connection_attempt_delaying

  def initialize(sock, addr)
    @sock = sock
    @addr = addr
    @mutex = Mutex.new
    @cond = ConditionVariable.new
    @connection_attempt_delaying = false
  end

  def worker
    @worker ||= Thread.start do
      @mutex.synchronize do
        @cond.wait(@mutex) if connection_attempt_delaying

        result = sock.connect(addr)

        if result == 0 # 成功
          sock.write "GET / HTTP/1.0\r\n\r\n"
          print sock.read
          sock.close
          (WORKING_THREADS.list - [Thread.current]).each(&:kill)
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

# アドレス解決
hostname = "localhost"
resolver = Resolv::DNS.new
ipv4_resource = resolver.getresource(hostname, Resolv::DNS::Resource::IN::A)
ipv6_resource = resolver.getresource(hostname, Resolv::DNS::Resource::IN::AAAA)

# 接続試行
port = 9292
ipv4_socket = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
ipv4_sockaddr = Socket.sockaddr_in(port, ipv4_resource.address.to_s)
WAITING_SOCKETS.push Client.new(ipv4_socket, ipv4_sockaddr)

ipv6_socket = Socket.new(Socket::AF_INET6, Socket::SOCK_STREAM, 0)
ipv6_sockaddr = Socket.sockaddr_in(port, ipv6_resource.address.to_s)
WAITING_SOCKETS.push Client.new(ipv6_socket, ipv6_sockaddr)

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
        @client.worker.run if @client.worker.status == 'sleep'
        break
      end

      sleep 0.001
    end
  end
end

WAITING_SOCKETS.each.with_index do |client, i|
  t = Thread.start(client) { |client|
    t = client.worker

    if (next_client = WAITING_SOCKETS[i + 1])
      next_client.connection_attempt_delaying = true
      ConnectionAttemptDelayTimer.new(Time.now, next_client).count
    end

    t.join
  }
  WORKING_THREADS.add t
end

WORKING_THREADS.list.each(&:join)
