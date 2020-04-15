# 引用: Working with TCP Sockets (Jesse Storimer)
# Server Lifecycle

require 'socket'

socket = Socket.new(:INET, :STREAM)

# リスニング用のアドレスを保持するC構造体を生成
# 第一引数 -> ポート
# 第二引数 -> ホスト
addr = Socket.pack_sockaddr_in(4481, '0.0.0.0')

# ソケットをアドレス構造体にバインド
socket.bind(addr)
