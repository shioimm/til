# 引用: Working with TCP Sockets (Jesse Storimer)
# Your First Socket

require 'socket'

socket = Socket.new(:INET6, :STREAM)

# IPv6ドメインによるTCPソケット
# Socket::AF_INET -> :INET
# Socket::SOCK_STREAM -> :STREAM
