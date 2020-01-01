# forkで並列処理を行う

require 'socket'

server = TCPServer.open(20000)

while true
  socket = server.accept

  fork do
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

      socket.puts res
      puts req
    ensure
      socket.close
    end
  end
end

# nc 127.0.0.1 20000でプロセスを起動
# curl http://127.0.0.1:20000/でアクセス
# => Hello!
# (-vオプションをつけるとステータスコードとヘッダも出力)
