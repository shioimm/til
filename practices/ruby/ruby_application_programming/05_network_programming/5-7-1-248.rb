# 引用: Rubyアプリケーションプログラミング P248

require 'socket'

sock = UDPSocket.open

while msg = STDIN.gets
  sock.send(msg, 0, 'localhost', 12345)
  print sock.recvfrom(1024).first
end

sock.close
