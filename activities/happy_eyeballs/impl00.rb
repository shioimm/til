require 'resolv'
require 'socket'

# TODO:
# AクエリとAAAAクエリをRFC8305に従ってそれぞれ送信する
# 取得したIPv4/IPv6アドレスをソートする (後回し)
# ソートしたアドレスをRFC8305に従って接続試行する

CONNECTION_ATTEMPT_DELAY = 0.25

q = Queue.new

# アドレス解決
hostname = "example.com"
resolver = Resolv::DNS.new
ipv4_resource = resolver.getresource(hostname, Resolv::DNS::Resource::IN::A)
ipv6_resource = resolver.getresource(hostname, Resolv::DNS::Resource::IN::AAAA)

# 接続試行
ipv4_socket = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
ipv4_sockaddr = Socket.sockaddr_in(80, ipv4_resource.address.to_s)
q.push({ sock: ipv4_socket, addr: ipv4_sockaddr})

ipv6_socket = Socket.new(Socket::AF_INET6, Socket::SOCK_STREAM, 0)
ipv6_sockaddr = Socket.sockaddr_in(80, ipv6_resource.address.to_s)
q.push({ sock: ipv6_socket, addr: ipv6_sockaddr})

while client = q.pop
  th = Thread.start do
    result = client[:sock].connect(client[:addr])
    # ここでCONNECTION_ATTEMPT_DELAY秒待つような仕組みが必要

    if result == 0 # 成功
      client[:sock].write "GET / HTTP/1.0\r\n\r\n"
      print client[:sock].read
      q.push(nil)
      # 接続待機または試行中の他のスレッドを終了させる
    end
  end

  th.join
end
