require 'resolv'
require 'socket'

# TODO:
# AクエリとAAAAクエリをRFC8305に従ってそれぞれ送信する
# 取得したIPv4/IPv6アドレスをソートする (後回し)
# ソートしたアドレスをRFC8305に従って接続試行する

# アドレス解決
hostname = "example.com"
resolver = Resolv::DNS.new
ipv4_resource = resolver.getresource(hostname, Resolv::DNS::Resource::IN::A)
ipv6_resource = resolver.getresource(hostname, Resolv::DNS::Resource::IN::AAAA)

# 接続試行
ipv4_socket = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
ipv4_sockaddr = Socket.sockaddr_in(80, ipv4_resource.address.to_s)
ipv4_socket.connect(ipv4_sockaddr)
ipv4_socket.write "GET / HTTP/1.0\r\n\r\n"
print ipv4_socket.read

ipv6_socket = Socket.new(Socket::AF_INET6, Socket::SOCK_STREAM, 0)
ipv6_sockaddr = Socket.sockaddr_in(80, ipv6_resource.address.to_s)
ipv6_socket.connect(ipv6_sockaddr)
ipv6_socket.write "GET / HTTP/1.0\r\n\r\n"
print ipv6_socket.read
