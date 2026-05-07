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
puts "\n"

puts "--- Socket.ip_sockets_port0(ai_list, reuseaddr) ---"
puts "\n"

puts "--- Socket.pack_sockaddr_in(port, host) ---"
puts "\n"

puts "--- Socket.pack_sockaddr_un(path) ---"
puts "\n"

puts "--- Socket.pair(*args) ---"
puts "\n"

puts "--- Socket.sockaddr_in(port, host) ---"
puts "\n"

puts "--- Socket.sockaddr_un(path) ---"
puts "\n"

puts "--- Socket.socketpair(*args) ---"
puts "\n"

puts "--- Socket.tcp(host, port, local_host = nil, local_port = nil, connect_timeout: nil, resolv_timeout: nil, fast_fallback: tcp_fast_fallback) ---"
puts "\n"

puts "--- Socket.tcp_fast_fallback ---"
puts "\n"

puts "--- Socket.tcp_fast_fallback= ---"
puts "\n"

puts "--- Socket.tcp_server_loop(host = nil, port, &b) ---"
puts "\n"

puts "--- Socket.tcp_server_sockets(host = nil, port) ---"
puts "\n"

puts "--- Socket.tcp_server_sockets_port0(host) ---"
puts "\n"

puts "--- Socket.tcp_with_fast_fallback(host, port, local_host = nil, local_port = nil, connect_timeout: nil, resolv_timeout: nil) ---"
puts "\n"

puts "--- Socket.udp_server_loop(host = nil, port, &b) ---"
puts "\n"

puts "--- Socket.udp_server_loop_on(sockets, &b) ---"
puts "\n"

puts "--- Socket.udp_server_recv(sockets) ---"
puts "\n"

puts "--- Socket.udp_server_sockets(host = nil, port) ---"
puts "\n"

puts "--- Socket.unix(path) ---"
puts "\n"

puts "--- Socket.unix_server_loop(path, &b) ---"
puts "\n"

puts "--- Socket.unix_server_socket(path) ---"
puts "\n"

puts "--- Socket.unpack_sockaddr_in(sockaddr) ---"
puts "\n"

puts "--- Socket.unpack_sockaddr_un(sockaddr) ---"
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
