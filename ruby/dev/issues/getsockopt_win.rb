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
    - `getsockopt(fptr->fd, level, option, buf, &len)` -> WSAから始まるエラーコード (WSAECONNREFUSEDなど) を取得
    - `rsock_sockopt_new(family, level, option, rb_str_new(buf, len))`
- ext/socket/option.c
  - rsock_sockopt_new
    - `sockopt_initialize(obj, INT2NUM(family), INT2NUM(level), INT2NUM(optname), data);`
    - VALUE data をintに変換 -> intをDWORDに変換するとrb_w32_map_errnoが使えるかもしれない

```c
getsockopt(fptr->fd, level, option, buf, &len)

DWORD winerr = (DWORD)buf;
int perrno = rb_w32_map_errno(winerr);

char err[16];
snprintf(err, sizeof(err), "%d", perrno);
rb_str_new(err, (long)strlen(err))
```

- win32/win32.c
  - rb_w32_map_errno
    - DWORD winerrを引数に渡すと、static const struct errmap[] テーブルからキーで値を検索して返す

SystemCallError
- error.c
  - syserr_initialize
    - `st_lookup(syserr_tbl, NUM2LONG(error), &data)`
  - setup_syserr (テーブルのセットアップ)
    - `st_add_direct(syserr_tbl, n, (st_data_t)error)`
