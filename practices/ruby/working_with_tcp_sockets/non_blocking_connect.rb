require 'socket'

socket = Socket.new(:AF_INET6, :SOCK_STREAM, 0)
sockaddr = Socket.sockaddr_in(80, 'www.google.com')

begin
  socket.connect_nonblock(sockaddr)
rescue IO::WaitWritable
  IO.select(nil, [socket])
  begin
    retry
  rescue Errno::EISCONN
  end
rescue Errno::EISCONN      # 多重接続
rescue Errno::EINPROGRESS  # 進行中
rescue Errno::EALREADY     # 前のノンブロッキング接続が進行中
rescue Errno::ECONNREFUSED # リモートホストが接続を拒否
end

socket.write("GET / HTTP/1.0\r\n\r\n")
results = socket.read
socket.close
p results
