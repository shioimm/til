require 'resolv'
require 'socket'

class Client
  attr_accessor :connection_attempt_delaying

  def initialize(sock, addr)
    @sock = sock
    @addr = addr
    @mutex = Mutex.new
    @cond = ConditionVariable.new
    @connection_attempt_delaying = true # デフォルトでfalseにするべき
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

CONNECTION_ATTEMPT_DELAY = 0.25

waiting_sockets = []
# TODO: 接続確立後に他の接続スレッドをkillする必要あり。ThreadGroupを使う?

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

# TODO:
#   ConnectionAttemptDelayTimerスレッド
#     1. 前のスレッドを表すインスタンスの接続開始時間を受け取り、タイマー計測
#     2. タイマー時間を経過したら次のスレッドを表すインスタンスに通知

while client = waiting_sockets.shift
  t = client.thread
  # TODO:
  #   CONNECTION_ATTEMPT_DELAY中
  #     -> client.connection_attempt_delaying = true
  #   CONNECTION_ATTEMPT_DELAY中以外
  #     -> client.connection_attempt_delaying = false
  #     -> 次のclient.connection_attempt_delaying = true
  client.connection_attempt_delaying = false
  t.run
  t.join
end
