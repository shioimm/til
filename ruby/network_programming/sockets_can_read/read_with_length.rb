# 引用: Working with TCP Sockets (Jesse Storimer)
# Sockets Can Read

require 'socket'

one_kb = 1024

Socket.tcp_server_loop(4481) do |connection|
  # 読み込むデータの最小長を指定する
  while data = connection.read(one_kb) do
    puts data
  end

  connection.close
end

# クライアントから最小長を下回るデータしか送信されなかった場合、
# サーバーは最小長を上回るデータが届くまでバッファリングを続けるため
# デッドロックが発生する可能性がある

# 回避策
# 1) クライアントがデータを送信した後にEOFを送信する
# 2) サーバーがpartial readを使用する
