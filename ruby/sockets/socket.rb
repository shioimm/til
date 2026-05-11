# https://www.rubydoc.info/stdlib/socket/4.0.0/Socket

require "socket"

puts "--- Socket.accept_loop(*sockets) ---"
# server = TCPServer.new("0.0.0.0", 4481)
# Socket.accept_loop(server) do |connection|
#   connection.accept
#   connection.close
#   break
# end
puts "\n"

puts "--- Socket.getaddrinfo(nodename, servname[, family[, socktype[, protocol[, flags[, reverse_lookup]]]]]) ---"
pp Socket.getaddrinfo("www.ruby-lang.org", 80, nil, :STREAM)
puts "\n"

puts "--- Socket.gethostbyaddr(address_string[, address_family]) ---"
# deprecated
# gethostbyname(3)
# [正式なホスト名, ホスト名のエイリアスの配列, アドレスファミリの定数値, アドレスのバイト列 (packed String), ...]
p Socket.gethostbyaddr([127, 0, 0, 1].pack("CCCC"))
puts "\n"

puts "--- Socket.gethostbyname(hostname) ---"
# deprecated
# gethostbyname(3)
# [正式なホスト名, ホスト名のエイリアスの配列, アドレスファミリの定数値, アドレスのバイト列 (packed String), ...]
p Socket.gethostbyname("localhost")
puts "\n"

puts "--- Socket.gethostname ---"
p Socket.gethostname
puts "\n"

puts "--- Socket.getifaddrs ---"
# NICのアドレスリスト (#<Socket::Ifaddr>)
pp Socket.getifaddrs
puts "\n"

puts "--- Socket.getnameinfo(sockaddr[, flags]) ---"
p Socket.getnameinfo(Socket.sockaddr_in('80','127.0.0.1'))
puts "\n"

puts "--- Socket.getservbyname(*args) ---"
p Socket.getservbyname("http", "tcp")
puts "\n"

puts "--- Socket.getservbyport(port[, protocol_name]) ---"
p Socket.getservbyport(80)
puts "\n"

puts "--- Socket.ip_address_list ---"
pp Socket.ip_address_list
puts "\n"

puts "--- Socket.pack_sockaddr_in(port, host) ---"
p Socket.sockaddr_in(80, "127.0.0.1")
puts "\n"

puts "--- Socket.pack_sockaddr_un(path) ---"
p Socket.sockaddr_un("/tmp/sock")
puts "\n"

puts "--- Socket.pair(*args) ---"
s1, s2 = Socket.pair(:UNIX, :STREAM, 0)
p s1, s2
s1.send("Hello", 0)
s1.close
p s2.recv(10)
p s2.recv(10)
s2.close
puts "\n"

puts "--- Socket.sockaddr_in(port, host) ---"
p Socket.sockaddr_in(80, "127.0.0.1")
puts "\n"

puts "--- Socket.sockaddr_un(path) ---"
p Socket.sockaddr_un("/tmp/sock")
puts "\n"

puts "--- Socket.socketpair(*args) ---"
s1, s2 = Socket.socketpair(:UNIX, :STREAM, 0)
p s1, s2
s1.send("Hello", 0)
s1.close
p s2.recv(10)
p s2.recv(10)
s2.close
puts "\n"
puts "\n"

puts "--- Socket.tcp(host, port, local_host = nil, local_port = nil, connect_timeout: nil, resolv_timeout: nil, fast_fallback: tcp_fast_fallback) ---"
p Socket.tcp("www.ruby-lang.org", 80)
puts "\n"

puts "--- Socket.tcp_fast_fallback ---"
p Socket.tcp_fast_fallback
puts "\n"

puts "--- Socket.tcp_fast_fallback= ---"
p Socket.tcp_fast_fallback = !Socket.tcp_fast_fallback
puts "\n"

puts "--- Socket.tcp_server_loop(host = nil, port, &b) ---"
# Socket.tcp_server_loop(16807) { |sock, client_addrinfo|
#   begin
#     IO.copy_stream(sock, sock)
#   ensure
#     sock.close
#   end
# }
puts "\n"

puts "--- Socket.tcp_server_sockets(host = nil, port) ---"
p Socket.tcp_server_sockets(1296)
puts "\n"

puts "--- Socket.udp_server_loop(host = nil, port, &b) ---"
# Socket.udp_server_loop(9261) { |msg, src|
#   src.reply msg
# }
puts "\n"

puts "--- Socket.udp_server_sockets(host = nil, port) ---"
udp_server_sockets = Socket.udp_server_sockets(0)
p udp_server_sockets
puts "\n"

puts "--- Socket.udp_server_loop_on(sockets, &b) ---"
# Socket.udp_server_loop_on(udp_server_sockets) { |msg, src|
#   p msg
#   p src.remote_address
#   src.reply msg
# }
puts "\n"

puts "--- Socket.udp_server_recv(sockets) ---"
# loop do
#   readable, = IO.select(udp_server_sockets)
#   Socket.udp_server_recv(readable) { |msg, src|
#     p msg
#     p src.remote_address
#     msg_src.reply msg
#   }
# end
puts "\n"

path = "/tmp/sock"

server = Thread.new {
  Socket.unix_server_loop(path) do |conn, addr|
    puts "--- Socket.unix_server_loop(path, &b) ---"
    p conn
    p addr
    conn.close
  end
}
sleep 0.05

Socket.unix(path) do |sock|
  puts "--- Socket.unix(path) ---"
  p sock
end
puts "\n"
server.kill
File.delete(path)

puts "--- Socket.unix_server_socket(path) ---"
p Socket.unix_server_socket("/tmp/sock")
puts "\n"

puts "--- Socket.unpack_sockaddr_in(sockaddr) ---"
sockaddr = Socket.sockaddr_in(80, "127.0.0.1")
p sockaddr
p Socket.unpack_sockaddr_in(sockaddr)
puts "\n"

puts "--- Socket.unpack_sockaddr_un(sockaddr) ---"
p sockaddr
sockaddr = Socket.sockaddr_un("/tmp/sock")
p Socket.unpack_sockaddr_un(sockaddr)
puts "\n"

puts "--- Socket#accept ---"
puts "\n"

puts "--- Socket#accept_nonblock(exception: true) ---"
puts "\n"

puts "--- Socket#bind(local_sockaddr) ---"
puts "\n"

puts "--- Socket#connect(remote_sockaddr) ---"
puts "\n"

puts "--- Socket#connect_nonblock(addr, exception: true) ---"
puts "\n"

puts "--- Socket#new(domain, socktype[, protocol]) ---"
puts "\n"

puts "--- Socket#ipv6only! ---"
puts "\n"

puts "--- Socket#listen(int) ---"
puts "\n"

puts "--- Socket#recvfrom(*args) ---"
puts "\n"

puts "--- Socket#recvfrom_nonblock(len, flag = 0, str = nil, exception: true) ---"
puts "\n"

puts "--- Socket#sysaccept ---"
