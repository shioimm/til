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
