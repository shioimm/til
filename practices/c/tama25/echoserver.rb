require 'socket'

Socket.tcp_server_loop(12345) do |sock|
  sock.puts("Request has been accepted:\n\n#{sock.readpartial(1024)}")
  sock.close
end
