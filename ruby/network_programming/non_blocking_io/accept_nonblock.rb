# 引用: Working with TCP Sockets (Jesse Storimer)
# Non-Blocking IO

require 'socket'

server = TCPServer.new(4481)

loop do
  begin
    connection.server.accept_nonblock
  rescue Errno::EAGAIN
    retry
  end
end

# リスナーキューから接続を取り出す際、
# キューに何もなければaccept_nonblockはErrno::EAGAIN を発生させる
