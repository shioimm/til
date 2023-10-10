require 'socket'

Socket.tcp_server_loop(4481) do |connection|
  loop do
    begin
      connection.read_nonblock(4096)
    rescue Errno::EAGAIN
      IO.select([connection])
      retry
    rescue EOFError
      break
    end
  end

  connection.close
end
