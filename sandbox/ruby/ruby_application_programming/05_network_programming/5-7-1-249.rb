# 引用: Rubyアプリケーションプログラミング P249

require 'socket'

sock = UDPSocket.open
sock.bind('', 12345)

loop do
  msg, (afam, port, host, ip) = sock.recvfrom(1024)
  sock.send(msg, 0, host, port)
end

sock.close
