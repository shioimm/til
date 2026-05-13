# https://www.rubydoc.info/stdlib/socket/4.0.0/Socket/AncillaryData

require "socket"

puts "--- Socket::AncillaryData.int(family, cmsg_level, cmsg_type, integer) ---"
# ファイルディスクリプタを別プロセスに渡す (SCM_RIGHTS) ための補助データ (UNIXドメインソケット)
p Socket::AncillaryData.int(:UNIX, :SOCKET, :RIGHTS, STDERR.fileno)

# 受信パケットのTTLを取得するための補助データ
p Socket::AncillaryData.int(:INET, :IP, :TTL, 64)

# IPv6パケットのホップ制限値を取得するための補助データ
p Socket::AncillaryData.int(:INET6, :IPV6, :HOPLIMIT, 128)
puts "\n"

# IP_PKTINFO: UDPソケットでパケットを受信したとき、どのインターフェースのどのアドレス宛に届いたか示す補助データ

puts "--- Socket::AncillaryData.ip_pktinfo(*args) ---"
addr = Addrinfo.ip("127.0.0.1")
ifindex = 0
spec_dst = Addrinfo.ip("127.0.0.1")
p Socket::AncillaryData.ip_pktinfo(addr, ifindex, spec_dst)
puts "\n"

puts "--- Socket::AncillaryData.ipv6_pktinfo(addr, ifindex) ---"
addr = Addrinfo.ip("::1")
ifindex = 0
p Socket::AncillaryData.ipv6_pktinfo(addr, ifindex)
puts "\n"

puts "--- Socket::AncillaryData.unix_rights(io1, io2, ...) ---"
puts "\n"

puts "--- Socket::AncillaryData#cmsg_is?(level, type) ---"
puts "\n"

puts "--- Socket::AncillaryData#data ---"
puts "\n"

puts "--- Socket::AncillaryData#family ---"
puts "\n"

puts "--- Socket::AncillaryData#Socket::AncillaryData.new(family, cmsg_level, cmsg_type, cmsg_data) ---"
puts "\n"

puts "--- Socket::AncillaryData#inspect ---"
puts "\n"

puts "--- Socket::AncillaryData#int ---"
puts "\n"

puts "--- Socket::AncillaryData#ip_pktinfo ---"
puts "\n"

puts "--- Socket::AncillaryData#ipv6_pktinfo ---"
puts "\n"

puts "--- Socket::AncillaryData#ipv6_pktinfo_addr ---"
puts "\n"

puts "--- Socket::AncillaryData#ipv6_pktinfo_ifindex ---"
puts "\n"

puts "--- Socket::AncillaryData#level ---"
puts "\n"

puts "--- Socket::AncillaryData#timestamp ---"
puts "\n"

puts "--- Socket::AncillaryData#type ---"
puts "\n"

puts "--- Socket::AncillaryData#unix_rights ---"
puts "\n"
