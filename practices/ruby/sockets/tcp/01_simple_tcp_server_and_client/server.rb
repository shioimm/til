# 引用元: rubyネットワークプログラミング  / 簡単なtcpサーバとクライアント
# http://www.geekpage.jp/programming/ruby-network/tcp-1.php
# 参照: https://docs.ruby-lang.org/ja/2.6.0/class/tcpserver.html
# 参照: https://docs.ruby-lang.org/ja/2.6.0/class/TCPSocket.html

require 'socket'

s0 = TCPServer.open(20000)
# ポート番号20000番で新しいサーバー接続をオープン
# TCPServer.openはTCPServer.newのエイリアス
# 内部でgetaddrinfo(3)を呼び出す
## getaddrinfo(3)
## https://kazmax.zpp.jp/cmd/g/getaddrinfo.3.html

sock = s0.accept
# クライアントからの接続要求を受け付ける
# TCPServer#acceptはTCPSocketのインスタンスを返す

while buf = sock.gets
  p buf
end
# クライアントからデータを受信する
# TCPSocket#gets(IO#gets)はテキストを一行ずつ読み込んで表示する

sock.close
# クライアントとの接続ソケットを閉じる

s0.close
# 待ち受けソケットを閉じる

# TCPSocket#closeとTCPServer#closeはIO#closeの継承
# 入出力ポートを閉じる
