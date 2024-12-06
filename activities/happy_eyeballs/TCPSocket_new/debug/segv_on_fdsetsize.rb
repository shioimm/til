# https://bugs.ruby-lang.org/issues/20932

require "socket"

open_fds = []

loop do
  file = open(__FILE__)
  open_fds << file

  # select(2) で監視できるfdの上限値 (1024) 近くまでfdを開く
  break if file.fileno >= 1010
end

TCPServer.open("localhost", 0) do |server|
  _, port, _ = server.addr
  sockets = []

  50.times do |i|
    # socket = Socket.tcp("localhost", port, fast_fallback: true) # 完了する
    socket = TCPSocket.new("localhost", port, fast_fallback: true) # 途中で止まる
    p socket
    sockets << socket
  end
end
