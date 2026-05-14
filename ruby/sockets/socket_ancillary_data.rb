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
# SCM_RIGHTS形式の補助データを取得
p Socket::AncillaryData.unix_rights(STDERR)
puts "\n"

puts "--- Socket::AncillaryData.new(family, cmsg_level, cmsg_type, cmsg_data) ---"
p data = Socket::AncillaryData.new(:INET6, :IPV6, :PKTINFO, "")
puts "\n"

puts "--- Socket::AncillaryData#cmsg_is?(level, type) ---"
p data.cmsg_is?(:IPV6, :IPV6_PKTINFO)
p data.cmsg_is?(:IPV6, :PKTINFO)
p data.cmsg_is?(:IP, :PKTINFO)
p data.cmsg_is?(:SOCKET, :RIGHTS)
puts "\n"

puts "--- Socket::AncillaryData#data ---"
p data.data
puts "\n"

puts "--- Socket::AncillaryData#family ---"
p data.family
puts "\n"

puts "--- Socket::AncillaryData#inspect ---"
p data.inspect
puts "\n"

puts "--- Socket::AncillaryData#int ---"
p Socket::AncillaryData.int(:UNIX, :SOCKET, :RIGHTS, STDERR.fileno).int
puts "\n"

puts "--- Socket::AncillaryData#ip_pktinfo ---"
addr = Addrinfo.ip("127.0.0.1")
ifindex = 0
spec_dest = Addrinfo.ip("127.0.0.1")
data = Socket::AncillaryData.ip_pktinfo(addr, ifindex, spec_dest)
p data.ip_pktinfo
puts "\n"

puts "--- Socket::AncillaryData#ipv6_pktinfo ---"
addr = Addrinfo.ip("::1")
ifindex = 0
data = Socket::AncillaryData.ipv6_pktinfo(addr, ifindex)
p data.ipv6_pktinfo
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
