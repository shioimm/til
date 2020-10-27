# 参照: rubyネットワークプログラミング / 何度も受信できるTCPサーバ
# http://www.geekpage.jp/programming/ruby-network/tcp-3.php
# 参照: RubyでシンプルなHTTPサーバを作る
# https://qiita.com/akiray03/items/3607c60ec8b221b3c2ba

require 'socket'

server = TCPServer.open(20000)

while true
  socket = server.accept

  req = []

  begin
    while message = socket.gets
      message.chomp!

      message.empty? ? break : req << message
    end

    res = <<~HTTP
      HTTP/1.1 200 OK
      Content-Type: text/plain

      Hello!
    HTTP

    # クライアント側で出力する
    socket.puts res
  # サーバー側で出力する
    puts req
  ensure
    socket.close
  end
end

# curl http://127.0.0.1:20000/でアクセス
# => Hello!
# (-vオプションをつけるとステータスコードとヘッダも出力)
