require 'resolv'
require 'socket'

# ここまでの実装:
#   アドレス解決 -> 同期的に実行
#   接続試行     -> 実装済み、接続と終了のそれぞれの条件で待機したいが別インスタンスの条件変数を取得できない
#                   インスタンスを共有してアドレスごとに別スレッドで立ち上げるのが良い?

# アドレス解決
hostname = "localhost"
resolver = Resolv::DNS.new
ipv4_resource = resolver.getresource(hostname, Resolv::DNS::Resource::IN::A)
ipv6_resource = resolver.getresource(hostname, Resolv::DNS::Resource::IN::AAAA)

# 接続試行
WAITING_SOCKETS = []
WORKING_THREADS = ThreadGroup.new

class Client
  attr_reader :connecting_starts_at

  def initialize(sock, addr)
    @sock = sock
    @addr = addr
    @mutex = Mutex.new
    @connectable = ConditionVariable.new
    @cancelable = ConditionVariable.new
    @connecting_starts_at = nil
  end

  def worker
    @worker ||= Thread.start do
      connect!
      cancel!
    end
  end

  def retry_to_connect!
    @connectable.signal
  end

  private

  attr_reader :sock, :addr

  def connect!
    @mutex.synchronize do
      ConnectionAttemptDelayTimer::DelayClient.new(self).attempt_to_connect if delaying?
      @connectable.wait(@mutex) if delaying?

      ConnectionAttemptDelayTimer::ConnectingClient.add self
      @connecting_starts_at = Time.now
      result = sock.connect(addr)

      if result == 0 # 成功
        sock.write "GET / HTTP/1.0\r\n\r\n"
        print sock.read
        sock.close
        # 他のワーカーの@cancelableに対してsingalしたい
      end
    end
  end

  def delaying?
    ConnectionAttemptDelayTimer.delaying?
  end

  def cancel!
    @mutex.synchronize do
      @cancelable.wait(@mutex) if attempting_to_connect?

      Thread.current.kill
    end
  end

  def attempting_to_connect?
    false
  end
end

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

  class ConnectingClient # TODO: Mutexで保護する必要あり
    @mutex = Mutex.new

    class << self
      def exist?
        @mutex.synchronize do
          !(@clients ||= []).empty?
        end
      end

      def add(client)
        @mutex.synchronize do
          (@clients ||= []) << client
        end
      end

      def update!
        @mutex.synchronize do
          (@clients ||= []).delete_at 0
        end
      end

      def timeout?
        @mutex.synchronize do
          Time.now > @clients.first.connecting_starts_at + CONNECTION_ATTEMPT_DELAY
        end
      end
    end
  end

  class DelayClient
    def initialize(client)
      @client = client
    end

    def attempt_to_connect
      loop do
        if !ConnectionAttemptDelayTimer.delaying?
          @client.retry_to_connect!
          ConnectingClient.update!
          break
        end

        sleep 0.001
      end
    end
  end
end

WAITING_SOCKETS.each.with_index do |client, i|
  t = Thread.start(client) { |client| t = client.worker; t.join; }
  WORKING_THREADS.add t
end

WORKING_THREADS.list.each(&:join)
