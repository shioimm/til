# 引用: Working with TCP Sockets (Jesse Storimer)
# Urgent Data

require 'socket'

Socket.tcp_server_loop(4481) do |connection|
  # ソケットのオプションにout-of-band data in-lineを設定
  # 帯域外のデータを帯域内で受信する
  # 緊急データは通常のデータストリームと順番に結合される
  connection.setsockopt(:SOCKET, :OOBINLINE, true)

  connection.readpartial(1024)
  connection.readpartial(1024)
end
