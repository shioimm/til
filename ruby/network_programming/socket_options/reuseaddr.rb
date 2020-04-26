# 引用: Working with TCP Sockets (Jesse Storimer)
# Socket Options

require 'socket'

server = TCPServer.new('localhost', 4481)

# ソケットのREUSEADDRオプションを有効にする
server.setsockopt(:SOCKET, :REUSEADDR, true)
# Socket::SO_REUSEADDR -> Allow local address reuse

server.getsockopt(:SOCKET, :REUSEADDR)

# TCPServer.new、Socket.tcp_server_loopなどはデフォルトでこのオプションを有効にしている
