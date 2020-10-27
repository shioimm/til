# 引用元: rubyネットワークプログラミング / UDPを使う
# http://www.geekpage.jp/programming/ruby-network/udp.php
# 参照: https://docs.ruby-lang.org/ja/2.6.0/class/UDPSocket.html
# 参照: https://docs.ruby-lang.org/ja/2.6.0/class/Socket.html
# 参照: https://docs.ruby-lang.org/ja/2.6.0/class/IPAddr.html
# 参照: https://docs.ruby-lang.org/ja/2.6.0/method/Array/i/pack.html

# ルータを越える通信を行いたい場合、マルチキャスト用TTLを変更する
# (初期設定ではマルチキャストパケットはTTL 1になっている)
# TTLはネットワーク上での最大転送回数
# 引用: http://e-words.jp/w/TTL-1.html
require 'socket'
require "ipaddr"

udp = UDPSocket.open()

sockaddr = Socket.pack_sockaddr_in(10000, '239.192.1.2')

udp.setsockopt(Socket::IPPROTO_IP, Socket::IP_MULTICAST_TTL, [3].pack("i"))
# Socket::IP_MULTICAST_TTLはIP multicast TTL(= 10)
# Array#packは引数(テンプレート)で指定された文字列に従い、自身をバイナリとしてパックした文字列を返す
# テンプレートiはリトルエンディアン / 32bit / int

mif = IPAddr.new('127.0.0.1').hton

udp.setsockopt(Socket::IPPROTO_IP, Socket::IP_MULTICAST_IF, mif)

udp.send('HELLO', 0, sockaddr)

udp.close
