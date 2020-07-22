# 引用: Working with TCP Sockets (Jesse Storimer)
# Server Lifecycle

require 'socket'

server = TCPServer.new(4481)

# acceptと無限ループの実行
Socket.accept_loop(server) do |connection|
  # connection = server.acceptの返り値と同じ
  connection.close
end

# accept_loopは複数のリスニングソケットを渡すことができる
# 渡されたソケットのうち、いずれかでacceptする
