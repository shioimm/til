# 引用: Working with TCP Sockets (Jesse Storimer)
# Sockets Can Read

require 'socket'

Socket.tcp_server_loop(4481) do |connection|
  # クライアントが終了するまでデータの読み込みを続ける
  puts connection.read # 接続ソケットからEOFまで読み込む
  connection.close
end
