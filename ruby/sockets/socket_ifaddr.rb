# https://www.rubydoc.info/stdlib/socket/4.0.0/Socket/Ifaddr

require "socket"

ifaddrs = Socket.getifaddrs

puts "--- Socket::Ifaddr#addr ---"
ifaddrs.each { p it.addr }
puts "\n"

puts "--- Socket::Ifaddr#broadaddr ---"
ifaddrs.each { it.broadaddr && p({ it => it.broadaddr }) }
puts "\n"

puts "--- Socket::Ifaddr#dstaddr ---"
ifaddrs.each { it.dstaddr && p({ it => it.dstaddr }) }
puts "\n"

puts "--- Socket::Ifaddr#flags ---"
ifaddrs.each { p({ it => it.flags }) }
puts "\n"

puts "--- Socket::Ifaddr#ifindex ---"
ifaddrs.each { p({ it => it.ifindex }) }
puts "\n"

puts "--- Socket::Ifaddr#inspect ---"
ifaddrs.each { p it.inspect }
puts "\n"

puts "--- Socket::Ifaddr#name ---"
ifaddrs.each { p({ it => it.name }) }
puts "\n"

puts "--- Socket::Ifaddr#netmask ---"
ifaddrs.each { p({ it => it.netmask }) }
puts "\n"

puts "--- Socket::Ifaddr#vhid ---"
# ifaddrs.each { it.vhid &&  p({ it => it.vhid }) }
