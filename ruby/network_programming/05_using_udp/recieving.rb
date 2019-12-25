# 引用元: rubyネットワークプログラミング / UDPを使う
# http://www.geekpage.jp/programming/ruby-network/udp.php
# 参照: https://docs.ruby-lang.org/ja/2.6.0/class/UDPSocket.html
# 参照: https://docs.ruby-lang.org/ja/2.6.0/class/Socket.html

require 'socket'

udps = UDPSocket.open()
# 新しいUDPソケットを返す
# 引数でアドレスファミリを指定
# (デフォルトでSocket::AF_INET(= 2 / IPv4)が適用される)

udps.bind('0.0.0.0', 10000)
# ソケットをhost(0.0.0.0)のport(10000)にbind(2)する
# bind(2) -> ソケットに名前をつける
# 引用元: https://linuxjm.osdn.jp/html/LDP_man-pages/man2/bind.2.html

p udps.recv(65535)
# bindしたポートからデータを受け取る
# BasicSocket#recvはソケットからデータを受け取り、文字列として返す

udps.close
# 入出力ポートをcloseする
