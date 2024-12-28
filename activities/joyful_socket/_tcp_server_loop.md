# `Socket.tcp_server_loop`

```ruby
require "socket"

Socket.tcp_server_loop(4567) do |sock, _ai|
  message = sock.recv 1000
  sock.sendmsg message
ensure
  sock.close
end
```

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
      # WIP: Addrinfo.foreach
      Addrinfo.foreach(host, port, nil, :STREAM, nil, Socket::AI_PASSIVE) {|ai|
        begin
          s = ai.listen # s = Socket
        rescue SystemCallError
          last_error = $!
          next
        end
        sockets << s
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
# Socket.accept_loop

def self.accept_loop(*sockets) # :yield: socket, client_addrinfo
  sockets.flatten!(1)

  if sockets.empty?
    raise ArgumentError, "no sockets"
  end

  loop {
    readable, _, _ = IO.select(sockets)

    readable.each {|r|
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

void
Init_socket(void)
{
    // ...

    /* for ext/socket/lib/socket.rb use only: */
    rb_define_private_method(rb_cSocket,
                             "__accept_nonblock", sock_accept_nonblock, 1);

    // ...
}
```

```c
// ext/socket/socket.c

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
}
```

```c
// ext/socket/init.c

VALUE
rsock_s_accept_nonblock(VALUE klass, VALUE ex, rb_io_t *fptr,
                        struct sockaddr *sockaddr, socklen_t *len)
{
    int fd2;

    rb_io_set_nonblock(fptr);
    fd2 = cloexec_accept(fptr->fd, (struct sockaddr*)sockaddr, len);

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
    return rsock_init_sock(rb_obj_alloc(klass), fd2);
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

        int result = accept4(socket, address, address_len, flags);
        if (result == -1) return -1;

        #ifndef SOCK_NONBLOCK
            rsock_make_fd_nonblock(result);
        #endif

    #else
        int result = accept(socket, address, address_len);
        if (result == -1) return -1;

        rb_maygvl_fd_fix_cloexec(result);
        rsock_make_fd_nonblock(result);
    #endif

    if (address_len && len0 < *address_len) *address_len = len0;
    return result;
}
```

```c
// ext/socket/init.c

VALUE
rsock_init_sock(VALUE sock, int fd)
{
    rb_io_t *fp;

    rb_update_max_fd(fd);
    MakeOpenFile(sock, fp);

    fp->fd = fd;
    fp->mode = FMODE_READWRITE|FMODE_DUPLEX;
    rb_io_ascii8bit_binmode(sock);

    if (rsock_do_not_reverse_lookup) {
        fp->mode |= FMODE_NOREVLOOKUP;
    }

    rb_io_synchronized(fp);

    return sock;
}
```

```c
// ext/socket/raddrinfo.c

VALUE
rsock_io_socket_addrinfo(VALUE io, struct sockaddr *addr, socklen_t len)
{
    rb_io_t *fptr;

    switch (TYPE(io)) {
      case T_FIXNUM:
        return rsock_fd_socket_addrinfo(FIX2INT(io), addr, len);

      case T_BIGNUM:
        return rsock_fd_socket_addrinfo(NUM2INT(io), addr, len);

      case T_FILE:
        GetOpenFile(io, fptr);
        return rsock_fd_socket_addrinfo(fptr->fd, addr, len);

      default:
        rb_raise(rb_eTypeError, "neither IO nor file descriptor");
    }

    UNREACHABLE_RETURN(Qnil);
}
```
