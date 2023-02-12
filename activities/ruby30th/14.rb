require "socket"

Socket.tcp_server_loop(12345) do |sock|
  sock.puts("#ruby30th")
  sock.close
end
