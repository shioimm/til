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
p Addrinfo.tcp("127.0.0.1", 54321).ipv4?
puts "\n"

puts "--- Addrinfo#ipv4_loopback? ---"
# 127.0.0.0/8ならtrue
p Addrinfo.tcp("127.0.0.1", 54321).ipv4_loopback?
puts "\n"

puts "--- Addrinfo#ipv4_multicast? ---"
# マルチキャストアドレス 224.0.0.0/4ならtrue
p Addrinfo.tcp("224.0.0.0", 54321).ipv4_multicast?
puts "\n"

puts "--- Addrinfo#ipv4_private? ---"
# プライベートアドレス 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16ならtrue
p Addrinfo.tcp("10.0.0.0", 54321).ipv4_private?
puts "\n"

puts "--- Addrinfo#ipv6? ---"
p Addrinfo.tcp("::1", 54321).ipv6?
puts "\n"

puts "--- Addrinfo#ipv6_linklocal? ---"
# リンクローカルアドレス fe80::/10ならtrue
#   同一リンク = 同一LANセグメントやWi-Fiネットワーク内でのみ有効なアドレス。ルータを越えて転送されない。
#   IPv6ではネットワークインターフェースに自動的に割り当てられるので、DHCPサーバがなくても同一リンク内で通信できる
p Addrinfo.tcp("fe80::", 54321).ipv6_linklocal?
puts "\n"

puts "--- Addrinfo#ipv6_loopback? ---"
p Addrinfo.tcp("::1", 54321).ipv6_loopback?
puts "\n"

puts "--- Addrinfo#ipv6_mc_global? ---"
# マルチキャスト (グローバルスコープ: インターネット全体) アドレスならtrue
p Addrinfo.tcp("::1", 54321).ipv6_mc_global?
puts "\n"

puts "--- Addrinfo#ipv6_mc_linklocal? ---"
# マルチキャスト (リンクローカルスコープ: 同一リンク内のみ) アドレスならtrue
p Addrinfo.tcp("::1", 54321).ipv6_mc_linklocal?
puts "\n"

puts "--- Addrinfo#ipv6_mc_nodelocal? ---"
# マルチキャスト (ノードローカルスコープ: 自分自身のノード内のみ) アドレスならtrue
p Addrinfo.tcp("::1", 54321).ipv6_mc_nodelocal?
puts "\n"

puts "--- Addrinfo#ipv6_mc_orglocal? ---"
# マルチキャスト (組織ローカルスコープ: 複数サイトにまたがる組織全体) アドレスならtrue
p Addrinfo.tcp("::1", 54321).ipv6_mc_orglocal?
puts "\n"

puts "--- Addrinfo#ipv6_mc_sitelocal? ---"
# マルチキャスト (サイトローカルスコープ: 組織内ネットワーク全体) アドレスならtrue
p Addrinfo.tcp("::1", 54321).ipv6_mc_sitelocal?
puts "\n"

puts "--- Addrinfo#ipv6_multicast? ---"
# マルチキャストアドレス ff00::/8ならtrue
#   1対多の通信に使われるアドレス
#   特定のグループ宛に同時送信でき、IPv4のマルチキャスト (224.0.0.0/4) に相当する
#   ffで始まるアドレスがすべて該当する
p Addrinfo.tcp("ff00::", 54321).ipv6_multicast?
puts "\n"

puts "--- Addrinfo#ipv6_sitelocal? ---"
# サイトローカルアドレス fec0::/10ならtrue
#   組織内ネットワーク (サイト) の範囲で有効なアドレス
#   IPv4のプライベートアドレス (192.168.x.x など) に相当する
#   RFC3879で非推奨となっており、現在はユニークローカルアドレス (fc00::/7) に置き換えられている
p Addrinfo.tcp("fec0::", 54321).ipv6_sitelocal?
puts "\n"

puts "--- Addrinfo#ipv6_to_ipv4 ---"
p Addrinfo.tcp("::192.0.2.0", 54321).ipv6_to_ipv4
puts "\n"

puts "--- Addrinfo#ipv6_unique_local? ---"
# ユニークローカルアドレス fc00::/7ならtrue
#   組織内のプライベートネットワーク向けアドレス
#   サイトローカル = 組織内で一意 / ユニークローカルアドレス = グローバルに一意
#   サイトローカルのように異なる組織が独立して生成したアドレスが偶然衝突する確率が低い
p Addrinfo.tcp("fc00::", 54321).ipv6_unique_local?
puts "\n"

puts "--- Addrinfo#ipv6_unspecified? ---"
# ::ならtrue
p Addrinfo.tcp("::", 54321).ipv6_unspecified?
puts "\n"

puts "--- Addrinfo#ipv6_v4compat? ---"
# 最初の80ビットがすべてゼロ ::/80ならtrue
p Addrinfo.tcp("::", 54321).ipv6_v4compat?
puts "\n"

puts "--- Addrinfo#ipv6_v4mapped? ---"
# IPv4-mapped IPv6アドレスのプレフィックス ::ffff:0:0 がついていればtrue
p Addrinfo.tcp("::ffff:0:0", 54321).ipv6_v4mapped?
puts "\n"

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
