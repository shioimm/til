# https://www.rubydoc.info/stdlib/socket/4.0.0/TCPSocket

require "socket"

puts "--- TCPSocket.gethostbyname ---"
pp TCPSocket.gethostbyname("www.ruby-lang.org")
puts "\n"

puts "--- TCPSocket.new ---"
p TCPSocket.open("www.ruby-lang.org", 80)
puts "\n"

puts "--- TCPSocket.open ---"
