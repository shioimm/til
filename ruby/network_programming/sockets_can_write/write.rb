# 引用: Working with TCP Sockets (Jesse Storimer)
# Sockets Can Write

require 'socket'

Socket.tcp_server_loop(4481) do |connection|
  # コネクションにデータを書き込む
  connection.write('Welcome!')
  connection.close
end
