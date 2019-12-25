# 引用元: rubyネットワークプログラミング / UDPを使う
# http://www.geekpage.jp/programming/ruby-network/udp.php
# 参照: https://docs.ruby-lang.org/ja/2.6.0/class/UDPSocket.html
# 参照: https://docs.ruby-lang.org/ja/2.6.0/class/Socket.html

require 'socket'

udp = UDPSocket.open()
# 新しいUDPソケットを返す
# 引数でアドレスファミリを指定
# (デフォルトでSocket::AF_INET(= 2 / IPv4)が適用される)

sockaddr = Socket.pack_sockaddr_in(10000, '127.0.0.1')
# Socket.pack_sockaddr_inは指定したアドレスを、ソケットアドレス構造体をpackした文字列として返す
# ソケットアドレス構造体は、接続に必要な通信プロトコルとアドレスとポートの情報を格納した構造体

udp.send('HELLO', 0, sockaddr)
# UDPソケットを介してデータを送る

udp.close
# 入出力ポートをcloseする
