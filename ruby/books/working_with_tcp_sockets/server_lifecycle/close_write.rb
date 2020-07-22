# 引用: Working with TCP Sockets (Jesse Storimer)
# Server Lifecycle

require 'socket'

server = Socket.new(:INET, :STREAM)
addr = Socket.pack_sockaddr_in(4481, '0.0.0.0')
server.bind(addr)
server.listen(128)

connection, _ = server.accept

# コネクション(read/write)を片方ずつcloseすることも可能
# 書き込みストリームを閉じる際、ソケットのもう片側にEOFが送信される
connection.close_write
connection.close_read

# close_write/close_readはshutdown(2)(接続の一部を完全にシャットダウン)
