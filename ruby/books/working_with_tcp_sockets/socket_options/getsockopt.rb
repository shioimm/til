# 引用: Working with TCP Sockets (Jesse Storimer)
# Socket Options

require 'socket'

socket = TCPSocket.new('google.com', 80)

# Socket::Optionインスタンス(ソケットタイプ)を取得
opt = socket.getsockopt(Socket::SOL_SOCKET, Socket::SO_TYPE)
# Socket::SOL_SOCKET -> Socket level options
# Sockets::SO_TYPE -> Get the socket type

opt.int == Socket::SOCK_STREAM
opt.int == Socket::SOCK_DGRM
# SocketOption#int -> 戻り値に関連付けられた整数
# Socket::SOCK_STREAM -> ストリーム通信
# ソケットタイプはストリーム通信であることがわかる
