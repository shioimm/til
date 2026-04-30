# https://www.rubydoc.info/stdlib/socket/4.0.0/Addrinfo

require "socket"

puts "--- Addrinfo.foreach ---"
Addrinfo.foreach("ruby-lang.org", 80) do |addrinfo|
  p addrinfo
end
puts "\n"

puts "--- Addrinfo.getaddrinfo ---"
pp Addrinfo.getaddrinfo("ruby-lang.org", 80)
puts "\n"

puts "--- Addrinfo.ip ---"
p Addrinfo.ip("ruby-lang.org")
puts "\n"

puts "--- Addrinfo.tcp ---"
p Addrinfo.tcp("ruby-lang.org", 80)
puts "\n"

puts "--- Addrinfo.udp ---"
p Addrinfo.udp("ruby-lang.org", 80)
puts "\n"

puts "--- Addrinfo.unix ---"
p Addrinfo.unix("ruby-lang.org", 80) # #<Addrinfo: UNIX ruby-lang.org SOCK_???(80)>
puts "\n"

puts "--- Addrinfo#afamily ---"
p Addrinfo.tcp("ruby-lang.org", 80).afamily
puts "\n"

puts "--- Addrinfo#bind ---"
p Addrinfo.tcp("127.0.0.1", 12345).bind
puts "\n"

puts "--- Addrinfo#canonname ---"
# Socket::AI_CANONNAMEの指定が必要
pp Addrinfo.getaddrinfo("ruby-lang.org", 80, nil, nil, nil, Socket::AI_CANONNAME).map(&:canonname)
puts "\n"

puts "--- Addrinfo#connect ---"
Addrinfo.tcp("www.ruby-lang.org", 80).connect {
  it.print "GET / HTTP/1.0\r\nHost: www.ruby-lang.org\r\n\r\n"
  puts it.readline
}
puts "\n"

puts "--- Addrinfo#connect_from ---"
Addrinfo.tcp("www.ruby-lang.org", 80).connect_from("::", 12345) {
  it.print "GET / HTTP/1.0\r\nHost: www.ruby-lang.org\r\n\r\n"
  puts it.readline
}
puts "\n"

puts "--- Addrinfo#connect_to ---"
Addrinfo.tcp("::", 54321).connect_to("www.ruby-lang.org", 80) {
  it.print "GET / HTTP/1.0\r\nHost: www.ruby-lang.org\r\n\r\n"
  puts it.readline
}
puts "\n"

puts "--- Addrinfo#family_addrinfo ---"
p Addrinfo.tcp("localhost", 54321).family_addrinfo("www.ruby-lang.org", 80)
puts "\n"

puts "--- Addrinfo#getnameinfo ---"
p Addrinfo.tcp("::1", 54321).getnameinfo()
puts "\n"

puts "--- Addrinfo#initialize ---"
p Addrinfo.new(Socket.sockaddr_in(54321, "localhost"))
puts "\n"

puts "--- Addrinfo#inspect ---"
p Addrinfo.tcp("localhost", 54321).inspect
puts "\n"

puts "--- Addrinfo#inspect_sockaddr ---"
p Addrinfo.tcp("localhost", 54321).inspect_sockaddr
puts "\n"

puts "--- Addrinfo#ip? ---"
p Addrinfo.tcp("localhost", 54321).ip?
puts "\n"

puts "--- Addrinfo#ip_address ---"
p Addrinfo.tcp("localhost", 54321).ip_address
puts "\n"

puts "--- Addrinfo#ip_port ---"
p Addrinfo.tcp("localhost", 54321).ip_port
puts "\n"

puts "--- Addrinfo#ip_unpack ---"
p Addrinfo.tcp("localhost", 54321).ip_unpack
puts "\n"

puts "--- Addrinfo#ipv4? ---"
p Addrinfo.tcp("localhost", 54321).ipv4?
puts "\n"

puts "--- Addrinfo#ipv4_loopback? ---"
p Addrinfo.tcp("localhost", 54321).ipv4_loopback?
puts "\n"

puts "--- Addrinfo#ipv4_multicast? ---"
p Addrinfo.tcp("localhost", 54321).ipv4_multicast?
puts "\n"

puts "--- Addrinfo#ipv4_private? ---"
p Addrinfo.tcp("localhost", 54321).ipv4_private?
puts "\n"

# ipv6?
# ipv6_linklocal?
# ipv6_loopback?
# ipv6_mc_global?
# ipv6_mc_linklocal?
# ipv6_mc_nodelocal?
# ipv6_mc_orglocal?
# ipv6_mc_sitelocal?
# ipv6_multicast?
# ipv6_sitelocal?
# ipv6_to_ipv4
# ipv6_unique_local?
# ipv6_unspecified?
# ipv6_v4compat?
# ipv6_v4mapped?
# listen(backlog = Socket::SOMAXCONN)
# marshal_dump
# marshal_load(ary)
# pfamily
# protocol
# socktype
# to_s
# to_sockaddr
# unix?
# unix_path
