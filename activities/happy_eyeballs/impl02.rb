require 'resolv'
require 'socket'

WAITING_SOCKETS = []
WORKING_THREADS = ThreadGroup.new

class Client
  attr_reader :connecting_starts_at

  def initialize(sock, addr)
    @sock = sock
    @addr = addr
    @mutex = Mutex.new
    @connecting_starts_at = nil
  end

  def worker
    @worker ||= Thread.start do
      @mutex.synchronize do
        if ConnectionAttemptDelayTimer.delaying?
          ConnectionAttemptDelayTimer::DelayClient.attempt_to_connect.join
        end

        ConnectionAttemptDelayTimer::ConnectingClient.add self
        @connecting_starts_at = Time.now
        result = sock.connect(addr)

        if result == 0 # 成功
          sock.write "GET / HTTP/1.0\r\n\r\n"
          print sock.read
          sock.close
        end
        (WORKING_THREADS.list - [Thread.current]).each(&:kill)
      end
    end
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

  def self.delaying?
    ConnectingClient.exist? && !(ConnectingClient.timeout?)
  end

  class ConnectingClient # TODO: 排他制御が必要な気がする
    class << self
      def exist?
        !(@clients ||= []).empty?
      end

      def add(client)
        (@clients ||= []) << client
      end

      def update!
        (@clients ||= []).delete_at 0
      end

      def timeout?
        Time.now > @clients.first.connecting_starts_at + CONNECTION_ATTEMPT_DELAY
      end
    end
  end

  class DelayClient
    def self.attempt_to_connect
      Thread.new do
        loop do
          if !ConnectionAttemptDelayTimer.delaying?
            ConnectingClient.update!
            break
          end

          sleep 0.001
        end
      end
    end
  end
end

WAITING_SOCKETS.each.with_index do |client, i|
  t = Thread.start(client) { |client|
    t = client.worker
    t.join
  }
  WORKING_THREADS.add t
end

WORKING_THREADS.list.each(&:join)
