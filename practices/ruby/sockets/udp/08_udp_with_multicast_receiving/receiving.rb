# 引用元: rubyネットワークプログラミング / UDPを使う
# http://www.geekpage.jp/programming/ruby-network/udp.php
# 参照: https://docs.ruby-lang.org/ja/2.6.0/class/UDPSocket.html
# 参照: https://docs.ruby-lang.org/ja/2.6.0/class/Socket.html

require 'socket'
require "ipaddr"

udps = UDPSocket.open()

udps.bind('0.0.0.0', 10000)

mreq = IPAddr.new('239.192.1.2').hton + IPAddr.new('0.0.0.0').hton

udps.setsockopt(Socket::IPPROTO_IP, Socket::IP_ADD_MEMBERSHIP, mreq)
# マルチキャストアドレスと利用するネットワークインターフェースを指定してマルチキャストグループに参加する
# Socket::IP_ADD_MEMBERSHIPはAdd a multicast group membership(= 12)

p udps.recv(65535)

udps.close
