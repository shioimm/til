# 引用: Working with TCP Sockets (Jesse Storimer)
# Server Lifecycle

require 'socket'

# 複数のサーバーソケットを配列で渡す
servers = Socket.tcp_server_sockets.new(4481)

Socket.accept_loop(servers) do |connection|
  connection.close
end
