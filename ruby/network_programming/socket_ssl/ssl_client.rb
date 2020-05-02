# 引用: Working with TCP Sockets (Jesse Storimer)
# Socket SSL

require 'socket'
require 'openssl'

socket = TCPSocket.new('0.0.0.0', 4481)
ssl_socket = OpenSSL::SSL::SSLSocket.new(socket)
ssl_socket.connect

ssl_socket.read
