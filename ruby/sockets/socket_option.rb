# https://www.rubydoc.info/stdlib/socket/4.0.0/Socket/AncillaryData

require "socket"

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

puts "--- Socket::Option.new(family, level, optname, data) ---"
sockopt = Socket::Option.new(:INET, :SOCKET, :KEEPALIVE, [1].pack("i"))
p sockopt
puts "\n"

puts "--- Socket::Option#bool ---"
p sockopt.bool
puts "\n"

puts "--- Socket::Option#data ---"
p sockopt.data
puts "\n"

puts "--- Socket::Option#family ---"
p sockopt.family
puts "\n"

puts "--- Socket::Option#inspect ---"
p sockopt.inspect
puts "\n"

puts "--- Socket::Option#int ---"
p sockopt.int
puts "\n"

puts "--- Socket::Option#level ---"
p sockopt.level
puts "\n"

puts "--- Socket::Option#linger ---"
p Socket::Option.linger(true, 10).linger
puts "\n"

puts "--- Socket::Option#optname ---"
p sockopt.optname
puts "\n"

puts "--- Socket::Option#to_s ---"
p sockopt.to_s
puts "\n"

puts "--- Socket::Option#unpack(template) ---"
p sockopt.unpack("i")
