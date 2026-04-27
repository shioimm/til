require 'socket'

begin
  socket = Socket.new(:INET, :STREAM)
  sockaddr = Socket.sockaddr_in(12345, "127.0.0.1")
  socket.connect_nonblock(sockaddr)
rescue IO::WaitWritable
  _, writable, = IO.select(nil, [socket], nil, nil)

  begin
    socket.connect_nonblock(sockaddr)
  rescue => e
    p e
  end
ensure
  socket.close if socket
end
