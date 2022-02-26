require 'socket'

Socket.tcp_server_loop(12345) { |sock, _client_addr_info|
  if sock.eof?
    sock.close
  else
    msg = sock.readpartial(1024)

    puts '--- Received ---'
    puts msg
    sock.puts msg
    puts '----------------'
  end
}
