# 引用: Rubyアプリケーションプログラミング P234

require 'socket'
require 'thread'


socket = TCPSocket.open('localhost', 12345)

th_get = Thread.start {
  while msg = socket.gets
    print msg
  end
}

th_ans = Thread.start {
  while msg = STDIN.gets
    socket.write msg
  end
  sock.shutdown(1)
}

th_get.join
th_ans.exit if th_ans.alive?
socket.close
