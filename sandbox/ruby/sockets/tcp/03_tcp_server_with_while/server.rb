# 引用元: rubyネットワークプログラミング / 何度も受信できるTCPサーバ
# http://www.geekpage.jp/programming/ruby-network/tcp-3.php

require 'socket'

s0 = TCPServer.open(20000)

# セッションをループさせる
while true
  ## クライアントからの接続要求を受け入れてセッションを開始
  ## -> 文字列を送信する
  ## -> セッションを終了する

  sock = s0.accept

  while buf = sock.gets
    p buf
  end

  sock.close
end

s0.close
# 終了条件をつけていないため、ソケットが閉じられることはない
