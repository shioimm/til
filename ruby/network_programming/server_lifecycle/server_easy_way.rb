# 引用: Working with TCP Sockets (Jesse Storimer)
# Server Lifecycle

require 'socket'

server = TCPServer.new(4481)

# ↓のコードとほぼ同じ
# server = Socket.new(:INET, :STREAM)
# addr = Socket.pack_sockaddr_in(4481, '0.0.0.0')
# server.bind(addr)
# server.listen(5)

# 相違点
#   TCPServer#acceptはコネクションのみを返す(リモートアドレスを返さない)
#   リスナーキューのサイズはデフォルトで5(TCPServer#listenで変更可)
