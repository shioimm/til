# `sock_connect_nonblock`

```c
// ext/socket/socket.c

static VALUE
sock_connect_nonblock(VALUE sock, VALUE addr, VALUE ex)
{
  VALUE rai;
  rb_io_t *fptr;
  int n;

  SockAddrStringValueWithAddrinfo(addr, rai);
  addr = rb_str_new4(addr);
  GetOpenFile(sock, fptr);
  rb_io_set_nonblock(fptr);
  n = connect(fptr->fd, (struct sockaddr*)RSTRING_PTR(addr), RSTRING_SOCKLEN(addr));

  if (n < 0) {
    int e = errno;

    if (e == EINPROGRESS) {
      if (ex == Qfalse) {
        return sym_wait_writable;
      }
      rb_readwrite_syserr_fail(RB_IO_WAIT_WRITABLE, e, "connect(2) would block");
    }

    if (e == EISCONN) {
      if (ex == Qfalse) {
        return INT2FIX(0);
      }
    }

    rsock_syserr_fail_raddrinfo_or_sockaddr(e, "connect(2)", addr, rai);
  }

  return INT2FIX(n);
}
```
