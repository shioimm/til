# https://www.rubydoc.info/stdlib/socket/4.0.0/Socket/AncillaryData

require "socket"

ifaddrs = Socket.getifaddrs

puts "--- Socket::Ifaddr#addr ---"
ifaddrs.each { p it.addr }
puts "\n"

puts "--- Socket::Ifaddr#broadaddr ---"
ifaddrs.each { it.broadaddr && (p it.broadaddr) }
puts "\n"

puts "--- Socket::Ifaddr#dstaddr ---"
puts "\n"

puts "--- Socket::Ifaddr#flags ---"
puts "\n"

puts "--- Socket::Ifaddr#ifindex ---"
puts "\n"

puts "--- Socket::Ifaddr#inspect ---"
puts "\n"

puts "--- Socket::Ifaddr#name ---"
puts "\n"

puts "--- Socket::Ifaddr#netmask ---"
puts "\n"

puts "--- Socket::Ifaddr#vhid ---"
