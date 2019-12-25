# 引用元: rubyネットワークプログラミング / UDPを使う
# http://www.geekpage.jp/programming/ruby-network/udp.php
# 参照: https://docs.ruby-lang.org/ja/2.6.0/class/UDPSocket.html
# 参照: https://docs.ruby-lang.org/ja/2.6.0/class/Socket.html
# 参照: https://docs.ruby-lang.org/ja/2.6.0/class/IPAddr.html

require 'socket'
require "ipaddr"

udp = UDPSocket.open()

sockaddr = Socket.pack_sockaddr_in(10000, '239.192.1.2')

mif = IPAddr.new('127.0.0.1').hton
# IPAddr.newはマスク値として127.0.0.1を指定したIPAddrオブジェクトを生成する
# IPAddr#htonはネットワークオーダーのバイト列に変換した文字列を返す
# ネットワークバイトオーダーは、
# ネットワークを通じて複数のバイト（多バイト、マルチバイト）で構成されるデータを記録・伝送する際に、
# 各バイトをどのような順番で記録・伝送するかを定めた順序
# 引用: http://e-words.jp/w/%E3%83%8D%E3%83%83%E3%83%88%E3%83%AF%E3%83%BC%E3%82%AF%E3%83%90%E3%82%A4%E3%83%88%E3%82%AA%E3%83%BC%E3%83%80%E3%83%BC.html

udp.setsockopt(Socket::IPPROTO_IP, Socket::IP_MULTICAST_IF, mif)
# ソケットのオプションを指定
# Socket::IPPROTO_IPはInternet protocol(= 0)
# Socket::IP_MULTICAST_IFはIP multicast interface(= 9)

udp.send('HELLO', 0, sockaddr)

udp.close
