# 参照: rubyネットワークプログラミング / IO::selectを使う
# http://www.geekpage.jp/programming/ruby-network/select-0.php
# 参照: irbから学ぶRubyの並列処理 ~ forkからWebSocketまで
# https://melborne.github.io/2011/09/29/irb-Ruby-fork-WebSocket/
# 参照: https://docs.ruby-lang.org/ja/2.6.0/class/IO.html

require 'socket'

server = TCPServer.open(20000)

sockets = [server]

while true
  r_sockets = IO.select(sockets)[0]
  # イベントの入力待ち
  # IO::selectは与えられた入力/出力/例外待ちのIO オブジェクトの中から準備ができたものをそれぞれ配列にした二次元配列を返す

  r_sockets.each do |socket|
    case socket
    when TCPServer # サーバーに対するクライアントの接続
      accepted_socket = socket.accept
      sockets << accepted_socket
      # クライアントからの接続要求を受けたソケットをsocketsに格納し、次のループに入る
    when TCPSocket # クライアントに対するデータの入力
      if socket.eof?
        # IO#eof?はストリームがファイルの終端に達したか真偽値を返す
        socket.close
        sockets.delete(socket)
      else
        req = []

        while message = socket.gets
          message.chomp.empty? ? break : req << message
        end

        res = <<~HTTP
          HTTP/1.1 200 OK
          Content-Type: text/plain

          Hello!
        HTTP

        socket.puts res
        puts req
      end
    end
  end
end
