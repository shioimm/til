# 引用元: rubyネットワークプログラミング / TCPサーバ(acceptした相手の確認)
# http://www.geekpage.jp/programming/ruby-network/accept-from.php
# 参照: https://docs.ruby-lang.org/ja/2.6.0/class/IPSocket.html

require 'socket'

s0 = TCPServer.open(20000)

while true
  sock = s0.accept

  p sock.peeraddr
  # IPSocket#peeraddrは接続先ソケットの情報を表す配列を返す

  while buf = sock.gets
    p buf
  end

  sock.close
end

s0.close
