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

// 引数を確認して rsock_init_inetsock() を呼び出す
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

// 引数を用意して init_inetsock_internal() inetsock_cleanup() を呼び出す
// Socket系インスタンスを生成する際、initializeメソッドとして呼び出される
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

struct inetsock_arg
{
  VALUE sock;

  struct {
    VALUE host, serv;
    struct rb_addrinfo *res;
  } remote, local;
  // (ext/socket/rubysocket.h)
  //   struct rb_addrinfo {
  //     struct addrinfo *ai;
  //     int allocated_by_malloc;
  //   };

  int type;
  int fd;
  VALUE resolv_timeout;
  VALUE connect_timeout;
};

// 終了処理
//   freeaddrinfo()を実行
//   fdを閉じる
static VALUE
inetsock_cleanup(VALUE v)
{
  struct inetsock_arg *arg = (void *)v;

  if (arg->remote.res) {
    rb_freeaddrinfo(arg->remote.res);
    arg->remote.res = 0;
  }

  if (arg->local.res) {
    rb_freeaddrinfo(arg->local.res);
    arg->local.res = 0;
  }

  if (arg->fd >= 0) {
    close(arg->fd);
  }
  return Qnil;
}

// シーケンシャルかつ同期的にアドレス解決・接続を試行し、接続に成功したソケットを rsock_init_sock() に渡す
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

  // connect_timeout がある場合は tv にセット
  if (!NIL_P(connect_timeout)) {
    tv_storage = rb_time_interval(connect_timeout);
    tv = &tv_storage;
  }

  // -----------------
  // 接続先のアドレス解決
  // -----------------
  // rsock_addrinfo() (ext/socket/raddrinfo.c) は
  // struct addrinfoに値をセットして rsock_getaddrinfo() を呼び出す関数
  arg->remote.res = rsock_addrinfo(
    arg->remote.host, // host (VALUE)
    arg->remote.serv, // port (VALUE)
    family,           // family
    SOCK_STREAM,      // socktype
    (type == INET_SERVER) ? AI_PASSIVE : 0 // flags
  );

  /*
   * Maybe also accept a local address
   */
  // TCPServer.new実行時、引数にlocal_hostやlocal_servが指定されている場合
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

  // addrinfo を順に試行する
  for (res = arg->remote.res->ai; res; res = res->ai_next) {

#if !defined(INET6) && defined(AF_INET6)
    // ホストがIPv6に対応していない場合、かつ ai_family がIPv6を指している場合はスキップ
    if (res->ai_family == AF_INET6) {
      continue;
    }
#endif

    lres = NULL;

    // TCPServer.new実行時、引数にlocal_hostやlocal_servが指定されている場合
    if (arg->local.res) {
      // 現在試行しているリモートアドレスaddrinfoの ai_family と
      // 同じ ai_family を持つローカルアドレスaddrinfoをlresに格納
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

    // -----------------
    // 接続ソケットの作成
    // -----------------
    // rsock_socket() (ext/socket/init.c) は socket() を呼び出してそのfdを返す関数
    // 失敗時は結果のステータスを返す
    status = rsock_socket(res->ai_family,res->ai_socktype,res->ai_protocol);
    syscall = "socket(2)";
    fd = status;

    // socket() 失敗時は次のループへスキップ
    if (fd < 0) {
      error = errno;
      continue;
    }

    arg->fd = fd;

    if (type == INET_SERVER) {
      // ...
    } else { // TCPSocket.new の場合typeは INET_CLIENT なのでここ
      // local_host の指定がある場合は取得したアドレスのaddrinfoとbind
      if (lres) {
#if !defined(_WIN32) && !defined(__CYGWIN__)
        status = 1;
        setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, (char*)&status, (socklen_t)sizeof(status));
#endif
        status = bind(fd, lres->ai_addr, lres->ai_addrlen);
        local = status;
        syscall = "bind(2)";
      }

      // -----------------
      // 接続試行
      // -----------------
      // ソケットの作成に成功している場合は rsock_connect() を呼び出す
      if (status >= 0) {
        status = rsock_connect(fd, res->ai_addr, res->ai_addrlen, (type == INET_SOCKS), tv);
        syscall = "connect(2)";
      }
    }

    // rsock_connect() の実行結果が失敗の場合、エラーを保存してfdをcloseし、次のループへ
    // そうでない場合はループから脱出
    if (status < 0) {
      error = errno;
      close(fd);
      arg->fd = fd = -1;
      continue;
    } else {
      break;
    }
  }

  // ループから抜けた時点 (接続に成功したか、試行するアドレス在庫が尽きた) の状況を確認
  // 失敗している場合は rsock_syserr_fail_host_port() を呼ぶ
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

  // TCPServer.new の場合typeは INET_CLIENT なのでここは通らない
  if (type == INET_SERVER) {
    // ...
  }

  /* create new instance */
  // 接続済みのソケットを rsock_init_sock() に渡してSocketインスタンスをつくる
  return rsock_init_sock(arg->sock, fd);
}
```

```c
// ext/socket/raddrinfo.c

struct rb_addrinfo*
rsock_addrinfo(VALUE host, VALUE port, int family, int socktype, int flags)
{
  struct addrinfo hints;

  MEMZERO(&hints, struct addrinfo, 1);
  hints.ai_family = family;
  hints.ai_socktype = socktype;
  hints.ai_flags = flags;

  return rsock_getaddrinfo(host, port, &hints, 1);
}
```

```c
// ext/socket/init.c

struct connect_arg {
  int fd;
  socklen_t len;
  const struct sockaddr *sockaddr;
};

int
rsock_connect(int fd, const struct sockaddr *sockaddr, int len, int socks, struct timeval *timeout)
{
  // 呼び出し側 (init_inetsock_internal())
  // int status = rsock_connect(fd, res->ai_addr, res->ai_addrlen, (type == INET_SOCKS), tv);
  //   fd  -> 接続を行うクライアントソケットのfd
  //   res -> リモートアドレス
  //   tv  -> connect_timeout

  int status;
  rb_blocking_function_t *func = connect_blocking;
  struct connect_arg arg;

  arg.fd = fd;
  arg.sockaddr = sockaddr;
  arg.len = len;

#if defined(SOCKS) && !defined(SOCKS5)
  if (socks) func = socks_connect_blocking;
#endif

  // (ext/socket/rubysocket.h)
  //   #define BLOCKING_REGION_FD(func, arg) (long)rb_thread_io_blocking_region((func), (arg), (arg)->fd)
  // func にはブロッキングモードで connect(2) を呼び、その結果をVALUE二キャストして返す関数が格納されている
  // BLOCKING_REGION_FDは func の実行結果 (VALUE) を返す
  // status にはそれをintとしてキャストした値が格納される
  status = (int)BLOCKING_REGION_FD(func, &arg);

  // connect(2) が返ってきたが、再試行可能である場合は wait_connectable() を呼ぶ
  if (status < 0) {
    switch (errno) {
      case EINTR:       // 関数呼び出しが割り込まれた
#ifdef ERESTART
      case ERESTART:    // システムコールが中断され再スタートが必要
#endif
      case EAGAIN:      // リソースが一時的に利用不可
#ifdef EINPROGRESS
      case EINPROGRESS: // 操作が実行中
#endif
        return wait_connectable(fd, timeout);
    }
  }

  // 実行結果 (成功の場合は0、上記以外の失敗の場合は-1) を返す
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
// thread.c
VALUE
rb_thread_io_blocking_region(rb_blocking_function_t *func, void *data1, int fd)
{
  volatile VALUE val = Qundef; /* shouldn't be used */
  rb_execution_context_t * volatile ec = GET_EC();
  volatile int saved_errno = 0;
  enum ruby_tag_type state;

  struct waiting_fd waiting_fd = {
    .fd = fd,
    .th = rb_ec_thread_ptr(ec),
    .busy = NULL,
  };

  // `errno` is only valid when there is an actual error - but we can't
  // extract that from the return value of `func` alone, so we clear any
  // prior `errno` value here so that we can later check if it was set by
  // `func` or not (as opposed to some previously set value).
  errno = 0;

  RB_VM_LOCK_ENTER();
  {
    ccan_list_add(&rb_ec_vm_ptr(ec)->waiting_fds, &waiting_fd.wfd_node);
  }
  RB_VM_LOCK_LEAVE();

  EC_PUSH_TAG(ec);
  if ((state = EC_EXEC_TAG()) == TAG_NONE) {
    BLOCKING_REGION(waiting_fd.th, {
      val = func(data1);
      saved_errno = errno;
    }, ubf_select, waiting_fd.th, FALSE);
  }
  EC_POP_TAG();

  /*
   * must be deleted before jump
   * this will delete either from waiting_fds or on-stack struct rb_io_close_wait_list
   */
  rb_thread_io_wake_pending_closer(&waiting_fd);

  if (state) {
    EC_JUMP_TAG(ec, state);
  }
  /* TODO: check func() */
  RUBY_VM_CHECK_INTS_BLOCKING(ec);

  // If the error was a timeout, we raise a specific exception for that:
  if (saved_errno == ETIMEDOUT) {
    rb_raise(rb_eIOTimeoutError, "Blocking operation timed out!");
  }

  errno = saved_errno;

  return val;
}
```

```c
// ext/socket/init.c

static int
wait_connectable(int fd, struct timeval *timeout)
{
  int sockerr, revents;
  socklen_t sockerrlen;

  sockerrlen = (socklen_t)sizeof(sockerr);

  // 発生したエラーの種類を取得してerrnoへ格納
  if (getsockopt(fd, SOL_SOCKET, SO_ERROR, (void *)&sockerr, &sockerrlen) < 0)
    return -1;

  // WIP ----------------------------
  /* necessary for non-blocking sockets (at least ECONNREFUSED) */
  switch (sockerr) {
    case 0:        // 気のせい(?)
      break;
#ifdef EALREADY
    case EALREADY: // ソケットがノンブロッキングモードに設定されており、 前の接続が完了していない
#endif
#ifdef EISCONN
    case EISCONN:  // 接続済み
#endif
#ifdef ECONNREFUSED
    case ECONNREFUSED: // 接続先がlistenしていない
#endif
#ifdef EHOSTUNREACH
    case EHOSTUNREACH: // ネットワークまたはホストへの経路がない
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