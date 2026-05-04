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

r, w = UNIXSocket.pair

puts "--- BasicSocket#close_read ---"
# static VALUE
# bsock_close_read(VALUE sock)
# {
#     rb_io_t *fptr;
#
#     GetOpenFile(sock, fptr);
#     shutdown(fptr->fd, SHUT_RD);
#     if (!(fptr->mode & FMODE_WRITABLE)) {
#         return rb_io_close(sock);
#     }
#     fptr->mode &= ~FMODE_READABLE;
#
#     return Qnil;
# }
p r.close_read
puts "\n"

puts "--- BasicSocket#close_write ---"
# static VALUE
# bsock_close_write(VALUE sock)
# {
#     rb_io_t *fptr;
#
#     GetOpenFile(sock, fptr);
#     if (!(fptr->mode & FMODE_READABLE)) {
#         return rb_io_close(sock);
#     }
#     shutdown(fptr->fd, SHUT_WR);
#     fptr->mode &= ~FMODE_WRITABLE;
#
#     return Qnil;
# }

p w.close_read
puts "\n"

puts "--- BasicSocket#connect_address ---"
# ローカルマシンで接続に適したソケットのアドレスを返す
p Addrinfo.tcp("0.0.0.0", 0).listen.connect_address
p Addrinfo.tcp("::", 0).listen.connect_address
puts "\n"

TCPSocket.open("www.ruby-lang.org", 80) { |sock|
  puts "--- BasicSocket#do_not_reverse_lookup ---"
  p sock.do_not_reverse_lookup
  puts "\n"

  puts "--- BasicSocket#do_not_reverse_lookup=(bool) ---"
  p sock.do_not_reverse_lookup = !sock.do_not_reverse_lookup
  puts "\n"
}

puts "--- BasicSocket#getpeereid ---"
# rb_undef_method(rb_cIPSocket, "getpeereid");↲されているので、
# BasicSocketを直接継承しているUNIXSocket (か、UNIXSocketを継承しているUNIXServer) でしか使えない
r, _w = UNIXSocket.pair
p r.getpeereid # [_wの実効UID, _wの実効GID]
puts "\n"

s = TCPSocket.new("www.ruby-lang.org", 80)

puts "--- BasicSocket#getpeername ---"
# 接続先のソケットの情報
p s.getpeername
p Socket.unpack_sockaddr_in(s.getpeername)
puts "\n"

puts "--- BasicSocket#getsockname ---"
# 自身の情報
p s.getsockname
p Socket.unpack_sockaddr_in(s.getsockname)
puts "\n"

puts "--- BasicSocket#getsockopt(level, optname) ---"
p s.getsockopt(Socket::IPPROTO_TCP, Socket::TCP_KEEPCNT)
puts "\n"

puts "--- BasicSocket#local_address ---"
# getsocknameで得られるのと同じ情報をAddrinfoオブジェクトとして表現する
p s.local_address
puts "\n"

puts "--- BasicSocket#read_nonblock(len, str = nil, exception: true) ---"
puts "--- BasicSocket#write_nonblock(buf, exception: true) ---"
puts "Linux-specific optimizations to avoid fcntl for IO#read_nonblock and IO#write_nonblock using MSG_DONTWAIT"
puts "Do other platforms support MSG_DONTWAIT reliably?"
puts "\n"

UNIXSocket.pair { |s1, s2|
  s1.puts "Hello World"
  puts "--- BasicSocket#recv(maxlen[, flags[, outbuf]]) ---"
  # recv(2)
  p s2.recv(4)
  puts "\n"

  puts "--- BasicSocket#recv_nonblock(len, flag = 0, str = nil, exception: true) ---"
  # recvfrom(2) ノンブロッキング
  p s2.recv_nonblock(4, Socket::MSG_PEEK)
  puts "\n"

  puts "--- BasicSocket#recvmsg(dlen = nil, flags = 0, clen = nil, scm_rights: false) ---"
  # recvmsg(2)
  p s2.recvmsg(4)
  puts "\n"

  puts "--- BasicSocket#recvmsg_nonblock(dlen = nil, flags = 0, clen = nil, scm_rights: false, exception: true) ---"
  # recvmsg(2) ノンブロッキング
  p s2.recvmsg_nonblock(10)
  puts "\n"
}

puts "--- BasicSocket#remote_address ---"
# getpeernameで得られるのと同じ情報をAddrinfoオブジェクトとして表現する
p s.remote_address
puts "\n"

puts "--- BasicSocket#send(mesg, flags[, dest_sockaddr]) ---"
puts "--- BasicSocket#sendmsg(mesg, flags = 0, dest_sockaddr = nil, *controls) ---"
puts "--- BasicSocket#sendmsg_nonblock(mesg, flags = 0, dest_sockaddr = nil, *controls, exception: true) ---"
puts "--- BasicSocket#setsockopt(*args) ---"
puts "--- BasicSocket#shutdown([how]) ---"
