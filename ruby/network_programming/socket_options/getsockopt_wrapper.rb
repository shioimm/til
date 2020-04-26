# 引用: Working with TCP Sockets (Jesse Storimer)
# Socket Options

require 'socket'

socket = TCPSocket.new('google.com', 80)

opt = socket.getsockopt(:SOCKET, :TYPE)
# :SOCKET -> Socket::SOL_SOCKET
# :TYPE -> Sockets::SO_TYPE
