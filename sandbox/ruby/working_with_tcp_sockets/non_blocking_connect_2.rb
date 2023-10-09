require 'socket'

socket = Socket.new(:AF_INET6, :SOCK_STREAM, 0)
sockaddr = Socket.sockaddr_in(80, 'www.google.com')
timeout = 5 # seconds

begin
  socket.connect_nonblock(sockaddr)
rescue Errno::EINPROGRESS
  if IO.select(nil, [socket], nil, timeout)
    retry
  else
    raise Timeout::Error
  end
rescue Errno::EISCONN
rescue Errno::EALREADY
rescue Errno::ECONNREFUSED
end

socket.write("GET / HTTP/1.0\r\n\r\n")
results = socket.read
socket.close
p results
