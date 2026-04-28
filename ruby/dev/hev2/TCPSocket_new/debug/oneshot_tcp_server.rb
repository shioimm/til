require 'socket'

server = TCPServer.new("localhost", 0)
serv_thread = Thread.new {server.accept}
begin sleep(0.1) end until serv_thread.stop?
p serv_thread

sock = TCPSocket.new("::1", server.addr[1])

p sock
p serv_thread

serv_thread.value.close
server.close
