# 引用: Working with TCP Sockets (Jesse Storimer)
# Client Lifecycle

require 'socket'

socket = TCPSocket.new('google.com', 80)
