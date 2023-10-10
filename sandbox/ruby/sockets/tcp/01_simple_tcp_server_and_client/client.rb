# 引用元: rubyネットワークプログラミング  / 簡単なtcpサーバとクライアント
# http://www.geekpage.jp/programming/ruby-network/tcp-1.php
# 参照: https://docs.ruby-lang.org/ja/2.6.0/class/tcpserver.html

require 'socket'

sock = TCPSocket.open('127.0.0.1', 20000)
# '127.0.0.1'(localhost)20000番に接続
# TCPSocket.openはTCPSocket.newのエイリアス
# 第一引数 -> ホスト / 第二引数 -> ポート
# 指定したホスト、ポートと接続したソケットを返す

sock.write('Hello')
# 文字列'Hello'を送信
# TCPSocket#write(IO#write)はIOポートに対して引数で渡した文字列を出力し
# 実際に出力できたバイト数を返す

sock.close
# 接続ソケットを閉じる
# TCPSocket#closeはIO#closeの継承
# 入出力ポートを閉じる
