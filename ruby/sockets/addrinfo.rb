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

# family_addrinfo(*args)
# getnameinfo(*args)
# initialize(*args)
# inspect
# inspect_sockaddr
# ip?
# ip_address
# ip_port
# ip_unpack
# ipv4?
# ipv4_loopback?
# ipv4_multicast?
# ipv4_private?
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
