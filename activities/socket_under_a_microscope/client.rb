require "socket"

Socket.tcp("localhost", 4567) do |sock|
  sock.write "Hi"
  message = sock.read
  puts message
end
