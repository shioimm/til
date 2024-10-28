require "socket"

serv = TCPServer.new(12543)
while sock = serv.accept
  p sock
end
