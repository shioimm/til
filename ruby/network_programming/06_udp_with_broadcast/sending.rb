# 引用元: rubyネットワークプログラミング / UDPでブロードキャストを使う
# http://www.geekpage.jp/programming/ruby-network/broadcast.php
# 参照: https://docs.ruby-lang.org/ja/2.6.0/class/UDPSocket.html
# 参照: https://docs.ruby-lang.org/ja/2.6.0/class/Socket.html

require 'socket'

udp = UDPSocket.open()

sockaddr = Socket.pack_sockaddr_in(10000, '255.255.255.255')
# 255.255.255.255はルータを超えないローカルネットワークのIPブロードキャストアドレス(リミテッドブロードキャストアドレス)
# サブネット内の全てのノードを指す

udp.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, 1)
# BasicSocket#setsockoptはソケットのオプションを設定する
# setsockopt(2)と同じ
# 参照: https://nxmnpg.lemoda.net/ja/2/setsockopt
# Socket::SOL_SOCKETはSocket level options(= 65535)
# Socket::SO_BROADCASTはPermit sending of broadcast messages(= 32)

udp.send('HELLO', 0, sockaddr)

udp.close
