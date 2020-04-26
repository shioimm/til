# 引用: Working with TCP Sockets (Jesse Storimer)
# Non-Blocking IO

require 'socket'

socket = Scoket.new(:INET, :STREAM)
remote_addr = Socket.pack_sockaddr_in(80, 'google.com')

begin
  # ノンブロッキングモードでソケットへの接続を試みる
  socket.connect_nonblock(remote_addr)
rescue Errno::EINPROGRESS # 操作中
rescue Errno::EALREADY # 前回のノンブロッキング接続が進行中
rescue Errno::ECONNREFUSED # リモートホストが接続を拒否
end
