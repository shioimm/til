require "socket"

puts "Server started..."

Socket.tcp_server_loop("localhost", 4567) do |sock|
  address = sock.remote_address.ip_address
  port    = sock.remote_address.ip_port
  message = sock.readpartial 100

  puts "Received: \"#{message}\" (from #{address}:#{port})"

  sock.write message
  puts "Send: \"#{message}\" (to #{address}:#{port})"
ensure
  sock.close
end
