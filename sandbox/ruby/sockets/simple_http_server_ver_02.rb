# 参照: RubyでシンプルなHTTPサーバを作る
# https://qiita.com/akiray03/items/3607c60ec8b221b3c2ba
# 参照: https://docs.ruby-lang.org/ja/2.6.0/class/Thread.html

# スレッドで並列処理を行う

require 'socket'

server = TCPServer.open(20000)

while true
  Thread.start(server.accept) do |socket|
    # Thread.startは新しいスレッド(Threadクラスのインスタンス)を生成してブロックを実行し、インスタンスを返す
    # 引数の返り値がブロック引数に入る

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
