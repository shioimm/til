# 引用: Rubyアプリケーションプログラミング P228

require 'socket'
require 'timeout'

sock = nil

timeout(20) {
 sock = TCPServer.open('echo')
}

while msg = STDIN.gets
  cnt = 0
  begin
    sock.write msg
    timeout(2) {
      print sock.gets
    }
  rescue TimeoutError
    if cnt < 3
      cnt += 1
      STDERR.print "TIMEOUT ERROR: retry: #{cnt}\n"
      retry
    else
      raise
    end
  end
end

sock.close
