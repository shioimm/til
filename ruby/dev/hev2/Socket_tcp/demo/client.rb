require "socket"

HOSTNAME = "localhost"
PORT = 4567

Socket.tcp(HOSTNAME, PORT) do |socket|
  socket.write "Hi\r\n"
  print socket.read
end
