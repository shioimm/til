# 引用: Working with TCP Sockets (Jesse Storimer)
# Server Lifecycle

require 'socket'

server = Socket.new(:INET, :STREAM)
addr = Socket.pack_sockaddr_in(4481, '0.0.0.0')
server.bind(addr)
server.listen(128)

connection, _ = server.accept

copy = connection.dup

# shutdown(2)はすべてのコネクションのコピーをshutdownする
connection.shutdown

# close(2)は元のコネクションをcloseする
# コピーはGCが回収した時点でcloseされる
connection.close
