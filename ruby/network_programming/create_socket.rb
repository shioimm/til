# 引用: Working with TCP Sockets (Jesse Storimer)
# Your First Socket

require 'socket'

socket = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM)

# IPv4ドメインによるストリーム通信のソケット
# AF_INET -> IPv4
# SOCK_STREAM -> TCPが提供するストリーム通信
# SOCK_DGRAM -> UDPが提供するデータグラム通信
# タイプはどのようなソケットを作成するかをカーネルに伝える
