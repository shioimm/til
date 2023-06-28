require 'resolv'
require 'socket'

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
# TODO:
#   接続確立後に他の接続スレッドをkillするため、接続待機中のスレッドを格納する配列とは別に
#   接続中のスレッドを格納する配列を別で用意した方が良いかも?

# アドレス解決
hostname = "localhost"
resolver = Resolv::DNS.new
ipv4_resource = resolver.getresource(hostname, Resolv::DNS::Resource::IN::A)
ipv6_resource = resolver.getresource(hostname, Resolv::DNS::Resource::IN::AAAA)

# 接続試行
port = 9292
ipv4_socket = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
ipv4_sockaddr = Socket.sockaddr_in(port, ipv4_resource.address.to_s)
waiting_sockets.push(Client.new(ipv4_socket, ipv4_sockaddr))

ipv6_socket = Socket.new(Socket::AF_INET6, Socket::SOCK_STREAM, 0)
ipv6_sockaddr = Socket.sockaddr_in(port, ipv6_resource.address.to_s)
waiting_sockets.push(Client.new(ipv6_socket, ipv6_sockaddr))

# TODO:
#   ConnectionAttemptDelayTimerスレッド
#     1. 前のスレッドを表すインスタンスの接続開始時間を受け取り、タイマー計測
#     2. タイマー時間を経過したら次のスレッドを表すインスタンスに通知

while client = waiting_sockets.shift
  th = Thread.start do
    # TODO:
    #   CONNECTION_ATTEMPT_DELAY中
    #     -> 通知が来るまで待機 (条件変数)
    #   CONNECTION_ATTEMPT_DELAY中以外
    #     -> 次のスレッドを表すインスタンスにCONNECTION_ATTEMPT_DELAYを開始、接続を開始
    result = client.sock.connect(client.addr)

    if result == 0 # 成功
      client.sock.write "GET / HTTP/1.0\r\n\r\n"
      print client.sock.read
      client.sock.close
      # TODO: 他の接続スレッドをkillする
    end
  end

  th.join
end
