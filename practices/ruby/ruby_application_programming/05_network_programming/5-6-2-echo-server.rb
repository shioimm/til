# 引用: Rubyアプリケーションプログラミング P225

require 'socket'

gate = TCPServer.open('echo')

sock = gate.accept

gate.close

while msg = sock.gets
  sock.write msg
end

sock.close
