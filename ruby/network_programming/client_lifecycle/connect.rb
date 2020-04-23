# 引用: Working with TCP Sockets (Jesse Storimer)
# Client Lifecycle

require 'socket'

# クライアントソケットは通常に明示的にbindされず
# ランダムなエフェメラルポートにbindされる

socket = Socket.new(:INET, :STREAM)

# google.comのポート80番へ接続を開始
remote_addr = Socket.pack_sockaddr_in(80, 'google.com')

# リモートソケットへの接続を開始
socket.connect(remote_addr)
