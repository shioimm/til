require "socket"

socket = TCPSocket.new("localhost", 4481)

socket.write "first"
socket.write "second"

socket.send '!', Socket::MSG_OOB

__END__
サーバがSocket::MSG_OOBでrecvしていない場合
socket.send '!', Socket::MSG_OOBの行は単に無視される
