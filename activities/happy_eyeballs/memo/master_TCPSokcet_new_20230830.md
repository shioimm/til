# `TCPSocket.new`の実装

```c
// ext/socket/tcpsocket.c

void
rsock_init_tcpsocket(void)
{
  // ...
  rb_cTCPSocket = rb_define_class("TCPSocket", rb_cIPSocket);
  // ...
  // メソッドの引数はCの配列として第二引数に入れて渡される
  rb_define_method(rb_cTCPSocket, "initialize", tcp_init, -1);
}
```

```c
// ext/socket/tcpsocket.c

static VALUE
tcp_init(int argc, VALUE *argv, VALUE sock)
{
  VALUE remote_host, remote_serv;
  VALUE local_host, local_serv;
  VALUE opt;
  static ID keyword_ids[2];
  VALUE kwargs[2];
  VALUE resolv_timeout = Qnil;
  VALUE connect_timeout = Qnil;

  if (!keyword_ids[0]) {
    CONST_ID(keyword_ids[0], "resolv_timeout");
    CONST_ID(keyword_ids[1], "connect_timeout");
  }

  rb_scan_args(argc, argv, "22:",
               &remote_host, &remote_serv,
               &local_host, &local_serv, &opt);

  if (!NIL_P(opt)) {
    rb_get_kwargs(opt, keyword_ids, 0, 2, kwargs);
    if (kwargs[0] != Qundef) { resolv_timeout = kwargs[0]; }
    if (kwargs[1] != Qundef) { connect_timeout = kwargs[1]; }
  }

  return rsock_init_inetsock(sock, remote_host, remote_serv,
                             local_host, local_serv, INET_CLIENT,
                             resolv_timeout, connect_timeout);
}
```

```c
// ext/socket/ipsocket.c

VALUE
rsock_init_inetsock(
  VALUE sock,
  VALUE remote_host,
  VALUE remote_serv,
  VALUE local_host,
  VALUE local_serv,
  int type,
  VALUE resolv_timeout,
  VALUE connect_timeout
)
{
  struct inetsock_arg arg;
  arg.sock = sock;
  arg.remote.host = remote_host;
  arg.remote.serv = remote_serv;
  arg.remote.res = 0;
  arg.local.host = local_host;
  arg.local.serv = local_serv;
  arg.local.res = 0;
  arg.type = type;
  arg.fd = -1;
  arg.resolv_timeout = resolv_timeout;
  arg.connect_timeout = connect_timeout;
  return rb_ensure(
    init_inetsock_internal,
    (VALUE)&arg,
    inetsock_cleanup,
    (VALUE)&arg
  );
}
```

```c
// ext/socket/ipsocket.c

static VALUE
init_inetsock_internal(VALUE v)
{
  struct inetsock_arg *arg = (void *)v;
  int error = 0;
  int type = arg->type;
  struct addrinfo *res, *lres;
  int fd, status = 0, local = 0;
  int family = AF_UNSPEC;
  const char *syscall = 0;
  VALUE connect_timeout = arg->connect_timeout;
  struct timeval tv_storage;
  struct timeval *tv = NULL;

  if (!NIL_P(connect_timeout)) {
    tv_storage = rb_time_interval(connect_timeout);
    tv = &tv_storage;
  }

  arg->remote.res = rsock_addrinfo(
    arg->remote.host,
    arg->remote.serv,
    family,
    SOCK_STREAM,
    (type == INET_SERVER) ? AI_PASSIVE : 0
  );

  /*
   * Maybe also accept a local address
   */

  if (type != INET_SERVER && (!NIL_P(arg->local.host) || !NIL_P(arg->local.serv))) {
    arg->local.res = rsock_addrinfo(
      arg->local.host,
      arg->local.serv,
      family,
      SOCK_STREAM,
      0
    );
  }

  arg->fd = fd = -1;

  for (res = arg->remote.res->ai; res; res = res->ai_next) {
#if !defined(INET6) && defined(AF_INET6)
    if (res->ai_family == AF_INET6) {
      continue;
    }
#endif
    lres = NULL;

    if (arg->local.res) {
      for (lres = arg->local.res->ai; lres; lres = lres->ai_next) {
        if (lres->ai_family == res->ai_family) {
          break;
        }
      }
      if (!lres) {
        if (res->ai_next || status < 0) {
          continue;
        }
        /* Use a different family local address if no choice, this
         * will cause EAFNOSUPPORT. */
        lres = arg->local.res->ai;
      }
    }

    status = rsock_socket(res->ai_family,res->ai_socktype,res->ai_protocol);
    syscall = "socket(2)";
    fd = status;

    if (fd < 0) {
      error = errno;
      continue;
    }

    arg->fd = fd;

    if (type == INET_SERVER) {
#if !defined(_WIN32) && !defined(__CYGWIN__)
      status = 1;
      setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, (char*)&status, (socklen_t)sizeof(status));
#endif
      status = bind(fd, res->ai_addr, res->ai_addrlen);
      syscall = "bind(2)";
    } else {
      if (lres) {
#if !defined(_WIN32) && !defined(__CYGWIN__)
        status = 1;
        setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, (char*)&status, (socklen_t)sizeof(status));
#endif
        status = bind(fd, lres->ai_addr, lres->ai_addrlen);
        local = status;
        syscall = "bind(2)";
      }

      if (status >= 0) {
        status = rsock_connect(fd, res->ai_addr, res->ai_addrlen, (type == INET_SOCKS), tv);
        syscall = "connect(2)";
      }
    }

    if (status < 0) {
      error = errno;
      close(fd);
      arg->fd = fd = -1;
      continue;
    } else {
      break;
    }

    if (status < 0) {
      VALUE host, port;

      if (local < 0) {
        host = arg->local.host;
        port = arg->local.serv;
      } else {
        host = arg->remote.host;
        port = arg->remote.serv;
      }

      rsock_syserr_fail_host_port(error, syscall, host, port);
    }

    arg->fd = -1;

    if (type == INET_SERVER) {
      status = listen(fd, SOMAXCONN);
      if (status < 0) {
        error = errno;
        close(fd);
        rb_syserr_fail(error, "listen(2)");
      }
    }

    /* create new instance */
    return rsock_init_sock(arg->sock, fd);
  }
}
```

```c
// ext/socket/init.c

int
rsock_connect(int fd, const struct sockaddr *sockaddr, int len, int socks, struct timeval *timeout)
{
  int status;
  rb_blocking_function_t *func = connect_blocking;
  struct connect_arg arg;

  arg.fd = fd;
  arg.sockaddr = sockaddr;
  arg.len = len;
#if defined(SOCKS) && !defined(SOCKS5)
  if (socks) func = socks_connect_blocking;
#endif
  status = (int)BLOCKING_REGION_FD(func, &arg);

  if (status < 0) {
    switch (errno) {
      case EINTR:
#ifdef ERESTART
      case ERESTART:
#endif
      case EAGAIN:
#ifdef EINPROGRESS
      case EINPROGRESS:
#endif
        return wait_connectable(fd, timeout);
    }
  }
    return status;
}
```

```c
// ext/socket/init.c

static VALUE
connect_blocking(void *data)
{
  struct connect_arg *arg = data;
  return (VALUE)connect(arg->fd, arg->sockaddr, arg->len);
}

#if defined(SOCKS) && !defined(SOCKS5)
static VALUE
socks_connect_blocking(void *data)
{
  struct connect_arg *arg = data;
  return (VALUE)Rconnect(arg->fd, arg->sockaddr, arg->len);
}
#endif
```

```c
// ext/socket/init.c

static int
wait_connectable(int fd, struct timeval *timeout)
{
  int sockerr, revents;
  socklen_t sockerrlen;

  sockerrlen = (socklen_t)sizeof(sockerr);
  if (getsockopt(fd, SOL_SOCKET, SO_ERROR, (void *)&sockerr, &sockerrlen) < 0)
      return -1;

  /* necessary for non-blocking sockets (at least ECONNREFUSED) */
  switch (sockerr) {
    case 0:
      break;
#ifdef EALREADY
    case EALREADY:
#endif
#ifdef EISCONN
    case EISCONN:
#endif
#ifdef ECONNREFUSED
    case ECONNREFUSED:
#endif
#ifdef EHOSTUNREACH
    case EHOSTUNREACH:
#endif
      errno = sockerr;
      return -1;
  }

  /*
   * Stevens book says, successful finish turn on RB_WAITFD_OUT and
   * failure finish turn on both RB_WAITFD_IN and RB_WAITFD_OUT.
   * So it's enough to wait only RB_WAITFD_OUT and check the pending error
   * by getsockopt().
   *
   * Note: rb_wait_for_single_fd already retries on EINTR/ERESTART
   */
  revents = rb_wait_for_single_fd(fd, RB_WAITFD_IN|RB_WAITFD_OUT, timeout);

  if (revents < 0)
    return -1;

  sockerrlen = (socklen_t)sizeof(sockerr);
  if (getsockopt(fd, SOL_SOCKET, SO_ERROR, (void *)&sockerr, &sockerrlen) < 0)
    return -1;

  switch (sockerr) {
    case 0:
    /*
     * be defensive in case some platforms set SO_ERROR on the original,
     * interrupted connect()
     */

      /* when the connection timed out, no errno is set and revents is 0. */
      if (timeout && revents == 0) {
        errno = ETIMEDOUT;
        return -1;
      }
    case EINTR:
#ifdef ERESTART
    case ERESTART:
#endif
    case EAGAIN:
#ifdef EINPROGRESS
    case EINPROGRESS:
#endif
#ifdef EALREADY
    case EALREADY:
#endif
#ifdef EISCONN
    case EISCONN:
#endif
      return 0; /* success */
    default:
      /* likely (but not limited to): ECONNREFUSED, ETIMEDOUT, EHOSTUNREACH */
      errno = sockerr;
      return -1;
  }

  return 0;
}
```