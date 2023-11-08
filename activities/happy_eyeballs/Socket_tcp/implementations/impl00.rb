require 'resolv'
require 'socket'

# ここまでの実装:
#   アドレス解決 -> 同期的に実行
#   接続試行     -> アドレスごとに別スレッドで実行、ConnectionAttemptDelayなし、両スレッドの実行を待機

# アドレス解決
hostname = "localhost"
resolver = Resolv::DNS.new
ipv4_resource = resolver.getresource(hostname, Resolv::DNS::Resource::IN::A)
ipv6_resource = resolver.getresource(hostname, Resolv::DNS::Resource::IN::AAAA)

# 接続試行
class Client
  # TODO: Threadをインスタンス変数に格納する
  # (その時点ではThread#stopで止めておく。CONNECTION_ATTEMPT_DELAYが解除されたらrun開始)
  attr_reader :sock, :addr

  def initialize(sock, addr)
    @sock = sock
    @addr = addr
  end
end

CONNECTION_ATTEMPT_DELAY = 0.25

waiting_sockets = []
port = 9292
ipv4_socket = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
ipv4_sockaddr = Socket.sockaddr_in(port, ipv4_resource.address.to_s)
waiting_sockets.push(Client.new(ipv4_socket, ipv4_sockaddr))

ipv6_socket = Socket.new(Socket::AF_INET6, Socket::SOCK_STREAM, 0)
ipv6_sockaddr = Socket.sockaddr_in(port, ipv6_resource.address.to_s)
waiting_sockets.push(Client.new(ipv6_socket, ipv6_sockaddr))

WORKING_THREADS = ThreadGroup.new

while client = waiting_sockets.shift
  t = Thread.start(client) do |client|
    # ConnectionAttemptDelayが必要
    result = client.sock.connect(client.addr)

    if result == 0 # 成功
      client.sock.write "GET / HTTP/1.0\r\n\r\n"
      print client.sock.read
      client.sock.close # 他の接続スレッドをkillする必要あり
    end
  end

  WORKING_THREADS.add t
end

WORKING_THREADS.list.each(&:join)
