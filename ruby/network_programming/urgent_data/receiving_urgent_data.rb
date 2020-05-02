# 引用: Working with TCP Sockets (Jesse Storimer)
# Urgent Data

require 'socket'

Socket.tcp_server_loop(4481) do |connection|
  # フラグ付きでソケットからデータを受け取る
  urgent_data = connection.recv(1, Socket::MSG_OOB)
  # 帯域外データが存在しない場合Errno::EINVAL↲が発生
  # TCPの実装では一度に1byteの緊急データしか送信できない
  # (最後の1byteだけが緊急とみなされる)

  # その他のデータを受信
  data = connection.readpartial(1024)
end
