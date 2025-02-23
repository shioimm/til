# `Socket.tcp_server_loop`

```ruby
require "socket"

Socket.tcp_server_loop("localhost", 4567) do |sock, _ai|
  message = sock.recv 1000
  sock.sendmsg message
ensure
  sock.close
end
```

#### 名前解決
- `Addrinfo.foreach` -> `Addrinfo.getaddrinfo`
  - クライアントと同じ

#### ソケット (Socketオブジェクト) の作成
- (`Addrinfo#listen` ->) `Socket.new`
  - クライアントと同じ

#### ソケットをアドレスにバインド
- (`Addrinfo#listen` ->) `Socket#bind`
  - `sock_bind`

#### 接続待機
- (`Addrinfo#listen` ->) `Socket#listen`
  - `rsock_sock_listen`

#### 接続受付
- `Socket#accept_nonblock`
  - `sock_accept_nonblock`
    - `rsock_s_accept_nonblock`
      - `cloexec_accept`

---

(2024/12/27)

```ruby
# Socket.tcp_server_loop

def self.tcp_server_loop(host=nil, port, &b) # :yield: socket, client_addrinfo
  tcp_server_sockets(host, port) {|sockets|
    accept_loop(sockets, &b)
  }
end
```

```ruby
# Socket.tcp_server_sockets

def self.tcp_server_sockets(host=nil, port)
  if port == 0
    # Addrinfo.getaddrinfo(host, 0, nil, :STREAM, nil, Socket::AI_PASSIVE) を実行する
    sockets = tcp_server_sockets_port0(host)
  else
    last_error = nil
    sockets = []

    begin
      Addrinfo.foreach(host, port, nil, :STREAM, nil, Socket::AI_PASSIVE) {|ai|
        begin
          s = ai.listen # Socket.new -> aiをbind(2) -> listen(2)
        rescue SystemCallError
          last_error = $!
          next
        end
        sockets << s # bindしたaiごとにSocketオブジェクトを収集
      }

      if sockets.empty?
        raise last_error
      end
    rescue Exception
      sockets.each(&:close)
      raise
    end
  end

  if block_given?
    begin
      yield sockets # => accept_loop(sockets, &b)
    ensure
      sockets.each(&:close)
    end
  else
    sockets
  end
end
```

```ruby
# Addrinfo#listen

def listen(backlog=Socket::SOMAXCONN)
  sock = Socket.new(self.pfamily, self.socktype, self.protocol)
  begin
    sock.ipv6only! if self.ipv6?
    sock.setsockopt(:SOCKET, :REUSEADDR, 1) unless self.pfamily == Socket::PF_UNIX
    sock.bind(self)
    sock.listen(backlog)
  rescue Exception
    sock.close
    raise
  end
  if block_given?
    begin
      yield sock
    ensure
      sock.close
    end
  else
    sock
  end
end
```

```c
// ext/socket/socket.c
// Socket#bind
// Socket#listen

void
init_socket(void)
{
    //...
    rb_define_method(rb_cSocket, "bind", sock_bind, 1);
    rb_define_method(rb_cSocket, "listen", rsock_sock_listen, 1);
    //...
}

// Socket#bind ---

static VALUE
sock_bind(VALUE sock, VALUE addr)
{
    VALUE rai;
    rb_io_t *fptr;

    SockAddrStringValueWithAddrinfo(addr, rai);
    GetOpenFile(sock, fptr);
    if (bind(fptr->fd, (struct sockaddr*)RSTRING_PTR(addr), RSTRING_SOCKLEN(addr)) < 0) // bind(2)
        rsock_sys_fail_raddrinfo_or_sockaddr("bind(2)", addr, rai);

    return INT2FIX(0);
}

// Socket#listen ---

VALUE
rsock_sock_listen(VALUE sock, VALUE log)
{
    rb_io_t *fptr;
    int backlog;

    backlog = NUM2INT(log);
    GetOpenFile(sock, fptr);
    if (listen(fptr->fd, backlog) < 0) // listen(2)
        rb_sys_fail("listen(2)");

    return INT2FIX(0);
}
```


```ruby
# Socket.accept_loop

def self.accept_loop(*sockets) # :yield: socket, client_addrinfo
  sockets.flatten!(1)

  if sockets.empty?
    raise ArgumentError, "no sockets"
  end

  loop {
    readable, _, _ = IO.select(sockets) # socketsが読み込み可能になるまで待機

    readable.each {|r| # 読み込み可能になったSocketオブジェクトごとにaccept
      sock, addr = r.accept_nonblock(exception: false)

      next if sock == :wait_readable

      yield sock, addr
    }
  }
end
```

```ruby
# Socket#accept_nonblock

def accept_nonblock(exception: true)
  __accept_nonblock(exception)
end
```

```c
// ext/socket/socket.c
// Socket#accept_nonblock

void
Init_socket(void)
{
    // ...

    /* for ext/socket/lib/socket.rb use only: */
    rb_define_private_method(rb_cSocket,
                             "__accept_nonblock", sock_accept_nonblock, 1);

    // ...
}

static VALUE
sock_accept_nonblock(VALUE sock, VALUE ex)
{
    rb_io_t *fptr;
    VALUE sock2;
    union_sockaddr buf;
    struct sockaddr *addr = &buf.addr;
    socklen_t len = (socklen_t)sizeof buf;

    GetOpenFile(sock, fptr);
    sock2 = rsock_s_accept_nonblock(rb_cSocket, ex, fptr, addr, &len);

    if (SYMBOL_P(sock2)) /* :wait_readable */
        return sock2;

    // VALUE rb_assoc_new(VALUE a, VALUE b) -> [a,b]
    return rb_assoc_new(sock2, rsock_io_socket_addrinfo(sock2, &buf.addr, len));

    // ext/socket/raddrinfo.c
    // VALUE
    // rsock_io_socket_addrinfo(VALUE io, struct sockaddr *addr, socklen_t len)
    // {
    //     rb_io_t *fptr;
    //
    //     switch (TYPE(io)) {
    //       case T_FIXNUM:
    //         return rsock_fd_socket_addrinfo(FIX2INT(io), addr, len);
    //
    //       case T_BIGNUM:
    //         return rsock_fd_socket_addrinfo(NUM2INT(io), addr, len);
    //
    //       case T_FILE:
    //         GetOpenFile(io, fptr);
    //         return rsock_fd_socket_addrinfo(fptr->fd, addr, len);
    //
    //       default:
    //         rb_raise(rb_eTypeError, "neither IO nor file descriptor");
    //     }
    //
    //     UNREACHABLE_RETURN(Qnil);
    // }
}

VALUE
rsock_s_accept_nonblock(VALUE klass, VALUE ex, rb_io_t *fptr,
                        struct sockaddr *sockaddr, socklen_t *len)
{
    int fd2;

    rb_io_set_nonblock(fptr);
    fd2 = cloexec_accept(fptr->fd, (struct sockaddr*)sockaddr, len); // accept(2)

    if (fd2 < 0) {
        int e = errno;

        switch (e) {
          case EAGAIN:
          #if defined(EWOULDBLOCK) && EWOULDBLOCK != EAGAIN
          case EWOULDBLOCK:
          #endif
          case ECONNABORTED:
          #if defined EPROTO
          case EPROTO:
          #endif
            if (ex == Qfalse)
                return sym_wait_readable;

            rb_readwrite_syserr_fail(RB_IO_WAIT_READABLE, e, "accept(2) would block");
        }

        rb_syserr_fail(e, "accept(2)");
    }

    rb_update_max_fd(fd2);
    return rsock_init_sock(rb_obj_alloc(klass), fd2); // ソケットをSocketオブジェクトにする
}
```

```c
// ext/socket/init.c

static int
cloexec_accept(int socket, struct sockaddr *address, socklen_t *address_len)
{
    socklen_t len0 = 0;
    if (address_len) len0 = *address_len;

    #ifdef HAVE_ACCEPT4
        int flags = SOCK_CLOEXEC;

        #ifdef SOCK_NONBLOCK
            flags |= SOCK_NONBLOCK;
        #endif

        // int accept4(int sockfd, struct sockaddr *addr, socklen_t *addrlen, int flags);
        //   flagsにはSOCK_NONBLOCK / SOCK_CLOEXECを指定できる
        //   Linux 2.6.28~
        int result = accept4(socket, address, address_len, flags);
        if (result == -1) return -1;

        #ifndef SOCK_NONBLOCK
            rsock_make_fd_nonblock(result);
        #endif

    #else
        // int accept(int sockfd, struct sockaddr *addr, socklen_t *addrlen);
        int result = accept(socket, address, address_len);
        if (result == -1) return -1;

        rb_maygvl_fd_fix_cloexec(result);
        rsock_make_fd_nonblock(result);

    #endif

    if (address_len && len0 < *address_len) *address_len = len0;
    return result;
}
```
