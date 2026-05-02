# https://www.rubydoc.info/stdlib/socket/4.0.0/BasicSocket

require "socket"

puts "--- BasicSocket.do_not_reverse_lookup ---"
p BasicSocket.do_not_reverse_lookup # true = 受信したソケットアドレスを逆引きしない
puts "\n"

puts "--- BasicSocket.do_not_reverse_lookup=(bool) ---"
p BasicSocket.do_not_reverse_lookup = false
puts "\n"

BasicSocket.do_not_reverse_lookup = true

puts "--- BasicSocket.for_fd(fd) ---"
# 別プロセスなどから取得したFDをBasicオブジェクトとして扱いたい
server = TCPServer.new("127.0.0.1", 0)
p BasicSocket.for_fd(server.fileno)
puts "\n"

puts "--- BasicSocket#close_read ---"
puts "--- BasicSocket#close_write ---"
puts "--- BasicSocket#connect_address ---"
puts "--- BasicSocket#do_not_reverse_lookup ---"
puts "--- BasicSocket#do_not_reverse_lookup=(bool) ---"
puts "--- BasicSocket#getpeereid ---"
puts "--- BasicSocket#getpeername ---"
puts "--- BasicSocket#getsockname ---"
puts "--- BasicSocket#getsockopt(level, optname) ---"
puts "--- BasicSocket#local_address ---"
puts "--- BasicSocket#read_nonblock(len, str = nil, exception: true) ---"
puts "--- BasicSocket#recv(maxlen[, flags[, outbuf]]) ---"
puts "--- BasicSocket#recv_nonblock(len, flag = 0, str = nil, exception: true) ---"
puts "--- BasicSocket#recvmsg(dlen = nil, flags = 0, clen = nil, scm_rights: false) ---"
puts "--- BasicSocket#recvmsg_nonblock(dlen = nil, flags = 0, clen = nil, scm_rights: false, exception: true) ---"
puts "--- BasicSocket#remote_address ---"
puts "--- BasicSocket#send(mesg, flags[, dest_sockaddr]) ---"
puts "--- BasicSocket#sendmsg(mesg, flags = 0, dest_sockaddr = nil, *controls) ---"
puts "--- BasicSocket#sendmsg_nonblock(mesg, flags = 0, dest_sockaddr = nil, *controls, exception: true) ---"
puts "--- BasicSocket#setsockopt(*args) ---"
puts "--- BasicSocket#shutdown([how]) ---"
puts "--- BasicSocket#write_nonblock(buf, exception: true) ---"
