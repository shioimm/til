# 引用: Working with TCP Sockets (Jesse Storimer)
# Server Lifecycle

require 'socket'

Socket.tcp_server_loop(4481) do |connection|
  connection.close
end

# ↓のコードと同じ
# servers = Socket.tcp_server_sockets.new(4481)
#
# Socket.accept_loop(servers) do |connection|
#   connection.close
# end
