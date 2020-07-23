# 引用: Working with TCP Sockets (Jesse Storimer)
# Timeouts

require 'socket'
require 'timeout'

socket = Socket.new(:INET, :STREAM)
remote_addr = Socket.pack_sockaddr_in(80, 'google.com')
timeout = 5

begin
  socket.connect_nonblock(remote_addr)
rescue Errno::EINPROGRESS # ソケットがノンブロッキングであり、接続をすぐに完了できない
  if IO.select(nil, [socket], nil, timeout)
    retry
  else
    raise Timeout::Error
  end
rescue Errno::EISCONN # ソケットが既に接続されている => 接続が正常に完了
end

socket.write('ohai') # 接続ソケットにデータを書き込む
socket.close
