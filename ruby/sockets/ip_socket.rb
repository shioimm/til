# https://www.rubydoc.info/stdlib/socket/4.0.0/IPSocket

require "socket"

puts "--- IPSocket.getaddress ---"
p IPSocket.getaddress("www.ruby-lang.org")
puts "\n"

sock = TCPSocket.open("www.ruby-lang.org", 80)

puts "--- IPSocket#addr([reverse_lookup]) ---"
p sock.addr
p sock.addr(true)
p sock.addr(false)
p sock.addr(:hostname)
p sock.addr(:numeric)
puts "\n"

puts "--- IPSocket#inspect ---"
p sock.inspect
puts "\n"

puts "--- IPSocket#peeraddr([reverse_lookup]) ---"
p sock.peeraddr
p sock.peeraddr(true)
p sock.peeraddr(false)
p sock.peeraddr(:hostname)
p sock.peeraddr(:numeric)
puts "\n"

puts "--- IPSocket#recvfrom(*args) ---"
u1 = UDPSocket.new
u1.bind("127.0.0.1", 4913)
u2 = UDPSocket.new
u2.send("Hello World", 0, "127.0.0.1", 4913)
p u1.recvfrom(10)
