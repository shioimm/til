require "socket"

Socket.tcp_server_loop(4481) do |connection|
  urgent_data = connection.recv(1, Socket::MSG_OOB)
  puts "urgent_data: #{urgent_data}"
  data = connection.readpartial(1024)
  puts "data: #{data}"
end

__END__
クライアントがSocket::MSG_OOBを送信していないとErrno::EINVALになる?

network/l4/tcp/msg_oob/server.rb:4:in 'BasicSocket#recv': Invalid argument - recvfrom(2) (Errno::EINVAL)
from network/l4/tcp/msg_oob/server.rb:4:in 'block in <main>'
from /Users/misaki-shioi/.rbenv/versions/3.4.1/lib/ruby/3.4.0/socket.rb:1226:in 'block (2 levels) in Socket.accept_loop'
