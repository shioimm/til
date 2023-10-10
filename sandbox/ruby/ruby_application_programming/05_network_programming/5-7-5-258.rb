# 引用: Rubyアプリケーションプログラミング P258

require 'socket'
require 'timeout'

sock = UDPSocket.open
sock.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)

begin
  sock.send('message', 0, '<broadcast>', 12345)
  timeout(5) {
    loop do
      msg, adr = sock.recvfrom(20)
      p addr
    end
  }
rescue TimeoutError
end

sock.close
