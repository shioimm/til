# 引用: Working with TCP Sockets (Jesse Storimer)
# Server Lifecycle

require 'socket'

socket = Socket.new(:INET, :STREAM)
addr = Socket.pack_sockaddr_in(4481, '0.0.0.0')
socket.bind(addr)

# クライアントからの接続をlistenする
# 引数 -> ソケットが許容する保留中のコネクションの最大数(listen queue)
# (queueがあふれた場合はErrno::ECONNREFUSED / queueの最大設定可能数はマシンによる)
socket.listen(5)
