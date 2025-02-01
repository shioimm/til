require "socket"

sock = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
addr = Socket.sockaddr_in(9999, "127.0.0.1")
sock.connect_nonblock(addr, exception: false)
_, _, excepts = IO.select(nil, nil, [sock], 5)
code = excepts.last.getsockopt(Socket::SOL_SOCKET, Socket::SO_ERROR).int

SystemCallError.new("Error", error_code)

__END__
- ext/socket/basicsocket.c
  - bsock_getsockopt
- ext/socket/option.c
  - rsock_sockopt_new
    - VALUE dataをintに変換 -> intをDWORDに変換するとrb_w32_map_errnoが使えるかもしれない
