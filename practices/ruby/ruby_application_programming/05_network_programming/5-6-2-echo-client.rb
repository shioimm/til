# 引用: Rubyアプリケーションプログラミング P223

require 'socket'

sock = TCPSocket.open('localhost', 'echo')

while msg = STDIN.gets
  sock.write msg
  print sock.gets
end

sock.close
