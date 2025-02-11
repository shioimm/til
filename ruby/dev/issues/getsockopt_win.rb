require "socket"

sock = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
addr = Socket.sockaddr_in(9999, "127.0.0.1")
sock.connect_nonblock(addr, exception: false)
_, _, excepts = IO.select(nil, nil, [sock], 5)
code = excepts.last.getsockopt(Socket::SOL_SOCKET, Socket::SO_ERROR).int

SystemCallError.new("Error", code)

__END__
# Windows 10 Version 22H2
require "socket"

sock = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
addr = Socket.sockaddr_in(9999, "127.0.0.1")
sock.connect_nonblock(addr, exception: false)
_, _, excepts = IO.select(nil, nil, [sock], 5)
code = excepts.last.getsockopt(Socket::SOL_SOCKET, Socket::SO_ERROR).int

SystemCallError.new("Error", code)
# => #<SystemCallError: No connection could be made because the target machine actively refused id. - connect(2) for 127.0.0.1:50306>

SystemCallError.new(Errno::ECONNREFUSED::Errno)
# => <Errno::ECONNREFUSED: No connection could be made because the target machine actively refused id.>

TCPSocket.new("127.0.0.1", 9999)
# => No connection could be made because the target machine actively refused id. - connect(2) for "127.0.0.1" port 9999 (Errno::ECONNREFUSED)

# macOS / Ubuntu
require "socket"
sock = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
addr = Socket.sockaddr_in(9999, "127.0.0.1")
sock.connect_nonblock(addr, exception: false)
_, writables, = IO.select(nil, [sock], nil, 5)
code = writables.last.getsockopt(Socket::SOL_SOCKET, Socket::SO_ERROR).int

SystemCallError.new("Error", code)
# => #<Errno::ECONNREFUSED: Connection refused - Error>

---

Socket#getsockopt
- ext/socket/basicsocket.c
  - bsock_getsockopt
- ext/socket/option.c
  - rsock_sockopt_new
    - VALUE dataをintに変換 -> intをDWORDに変換するとrb_w32_map_errnoが使えるかもしれない

SystemCallError
- error.c
  - syserr_initialize
    - `st_lookup(syserr_tbl, NUM2LONG(error), &data)`
  - setup_syserr (テーブルのセットアップ)
    - `st_add_direct(syserr_tbl, n, (st_data_t)error)`
