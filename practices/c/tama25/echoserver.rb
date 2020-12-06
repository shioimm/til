require 'socket'

Socket.tcp_server_loop(12345) do |sock|
  req = sock.readpartial(1024)
  sock.puts("Message from client: #{req.split.last}")
  sock.close
end
