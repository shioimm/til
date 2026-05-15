# https://www.rubydoc.info/stdlib/socket/4.0.0/Socket/AncillaryData

require "socket"

puts "--- Socket::Option.new(family, level, optname, data) ---"
sockopt = Socket::Option.new(:INET, :SOCKET, :KEEPALIVE, [1].pack("i"))
p sockopt
puts "\n"

puts "--- Socket::Option.bool(family, level, optname, bool) ---"
p Socket::Option.bool(:INET, :SOCKET, :KEEPALIVE, true)
puts "\n"

puts "--- Socket::Option.byte(family, level, optname, integer) ---"
p Socket::Option.byte(:INET, :SOCKET, :KEEPALIVE, 1)
puts "\n"

puts "--- Socket::Option.int(family, level, optname, integer) ---"
p Socket::Option.int(:INET, :SOCKET, :KEEPALIVE, 1)
puts "\n"

puts "--- Socket::Option.ipv4_multicast_loop(integer) ---"
p Socket::Option.int(:INET, :IPPROTO_IP, :IP_MULTICAST_LOOP, 1)
puts "\n"

puts "--- Socket::Option.ipv4_multicast_ttl(integer) ---"
p Socket::Option.ipv4_multicast_ttl(10)
puts "\n"

puts "--- Socket::Option.linger(onoff, secs) ---"
p Socket::Option.linger(true, 10)
puts "\n"

puts "--- Socket::Option#bool ---"
puts "\n"

puts "--- Socket::Option#byte ---"
puts "\n"

puts "--- Socket::Option#data ---"
puts "\n"

puts "--- Socket::Option#family ---"
puts "\n"

puts "--- Socket::Option#inspect ---"
puts "\n"

puts "--- Socket::Option#int ---"
puts "\n"

puts "--- Socket::Option#ipv4_multicast_loop ---"
puts "\n"

puts "--- Socket::Option#ipv4_multicast_ttl ---"
puts "\n"

puts "--- Socket::Option#level ---"
puts "\n"

puts "--- Socket::Option#linger ---"
puts "\n"

puts "--- Socket::Option#optname ---"
puts "\n"

puts "--- Socket::Option#to_s ---"
puts "\n"

puts "--- Socket::Option#unpack(template) ---"
