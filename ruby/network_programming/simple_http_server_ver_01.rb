# 参照: rubyネットワークプログラミング / 何度も受信できるTCPサーバ
# http://www.geekpage.jp/programming/ruby-network/tcp-3.php
# 参照: RubyでシンプルなHTTPサーバを作る
# https://qiita.com/akiray03/items/3607c60ec8b221b3c2ba

require 'socket'

server = TCPServer.open(20000)

while true
  socket = server.accept

  req = []

  while message = socket.gets
    message.chomp!

    message.empty? ? break : req << message
  end

  # クライアント側で出力する
  socket.puts 'HTTP/1.1 200 OK'
  socket.puts 'Content-Type: text/plain'
  socket.puts "\r\n"
  socket.puts 'Hello!'

  # サーバー側で出力する
  puts req

  socket.close
end

# curl http://127.0.0.1:20000/でアクセス
# => Hello!
# (-vオプションをつけるとステータスコードとヘッダも出力)
