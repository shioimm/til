# PR4262の`TCPSocket.new`の実装
- 接続試行のみ対応

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

#if defined(F_SETFL) && defined(F_GETFL) // if nonblocking mode is available
  // Happy Eyeballs 2を適用する場合
  // init_inetsock_internal_happy() を呼び出す
  if (type == INET_CLIENT) {
    return rb_ensure(init_inetsock_internal_happy, (VALUE)&arg, inetsock_cleanup, (VALUE)&arg);
  }
#endif

  // Happy Eyeballs 2を適用しない場合
  return rb_ensure(init_inetsock_internal, (VALUE)&arg, inetsock_cleanup, (VALUE)&arg);
}
```

```c
// ext/socket/ipsocket.c

#if defined(F_SETFL) && defined(F_GETFL)

#define CONNECTION_ATTEMPT_DELAY_USEC 250000 /* 250ms is a recommended value in RFC8305 */

static VALUE
init_inetsock_internal_happy(VALUE v)
{
  struct inetsock_arg *arg = (void *)v;

  // (ext/socket/ipsocket.c)
  //   struct inetsock_arg
  //   {
  //     VALUE sock;
  //
  //     struct {
  //       VALUE host, serv;
  //       struct rb_addrinfo *res;
  //     } remote, local;
  //     // (ext/socket/rubysocket.h)
  //     //   struct rb_addrinfo {
  //     //     struct addrinfo *ai;
  //     //     int allocated_by_malloc;
  //     //   };
  //
  //     int type;
  //     int fd;
  //     VALUE resolv_timeout;
  //     VALUE connect_timeout;
  //   };

  struct addrinfo *res, *lres;

  int fd,
      nfds,
      error = 0,
      status = 0,
      local = 0,
      family = AF_UNSPEC;

  const char *syscall = 0;
  rb_fdset_t writefds;
  VALUE fds_ary = rb_ary_tmp_new(1);
  struct timeval connection_attempt_delay;

  rb_hrtime_t rel = 0,
              end = 0,
              *limit = NULL;

  // connect_timeout がある場合 rel, limit, end にセット
  if (!NIL_P(arg->connect_timeout)) {
      struct timeval timeout = rb_time_interval(arg->connect_timeout);
      rel = rb_timeval2hrtime(&timeout);
      limit = &rel;
      end = rb_hrtime_add(rb_hrtime_now(), rel);
  }

  // rsock_addrinfo() (ext/socket/raddrinfo.c) は
  // struct addrinfoに値をセットして rsock_getaddrinfo() を呼び出す関数
  arg->remote.res = rsock_addrinfo(
    arg->remote.host,
    arg->remote.serv,
    family,
    SOCK_STREAM,
    0
  );

  /*
   * Maybe also accept a local address
   */
  // TCPServer.new実行時、引数にlocal_hostやlocal_servが指定されている場合
  if (!NIL_P(arg->local.host) || !NIL_P(arg->local.serv)) {
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

    // 作成したソケットをノンブロッキングモードにする
    socket_nonblock_set(fd, true);

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

    // ソケットの作成に成功している場合 (status = fd) は connect(2) を呼び出す
    if (status >= 0) {
      // fdがノンブロッキングモードなのでブロックしない
      status = connect(fd, res->ai_addr, res->ai_addrlen);
      syscall = "connect(2)";
    }

    // connect(2) の実行結果が失敗であり、かつ EINPROGRESS (接続試行中) ではない場合
    if (status < 0 && errno != EINPROGRESS) {
      // ソケットを閉じて次のループへスキップ
      error = errno;
      close(fd);
      arg->fd = fd = -1;
      continue;
    } else { // connect() で接続できた場合もしくは EINPROGRESS の場合
      rb_ary_push(fds_ary, INT2FIX(fd)); // fds_ary << 接続できたソケットのfd
      nfds = set_fds(fds_ary, &writefds); // nfds は監視対象のfdの集合

      /* connection_attempt_delay may be modified by select(2) in linux */
      connection_attempt_delay.tv_sec = 0;
      connection_attempt_delay.tv_usec = CONNECTION_ATTEMPT_DELAY_USEC;

      // select(2) を呼び出す、Connection Attempt Delayでタイムアウトを設定
      status = rb_thread_fd_select(nfds, NULL, &writefds, NULL, &connection_attempt_delay);
      syscall = "select(2)";

      // 接続完了、もしくはタイムアウト
      if (status >= 0) {
        arg->fd = fd = find_connected_socket(fds_ary, &writefds);
        // 接続済みのソケットが見つかればこの時点でループから脱出
        // arg->fd に対象のソケットの fd が格納されている
        if (fd >= 0) { break; }
        status = -1; // no connected socket found
      }

      error = errno;
    }
  }

  /* wait connection */
  // 上記の find_connected_socket() が-1を返している (接続済みのソケットが見つからなかった) 場合
  while (fd < 0 && RARRAY_LEN(fds_ary) > 0) {
    struct timeval tv_storage, *tv = NULL;

    if (limit) { // if timeout is specified
      if (hrtime_update_expire(limit, end)) { // check if timeout has expired and update timeout
        // connect_timeout した場合
        status = -1;
        error = ETIMEDOUT;
        break;
      }
      rb_hrtime2timeval(&tv_storage, limit); // set new timeout
      tv = &tv_storage;
    }

    nfds = set_fds(fds_ary, &writefds);
    // 接続中のソケットに対して select(2) を呼び出す
    status = rb_thread_fd_select(nfds, NULL, &writefds, NULL, tv);
    syscall = "select(2)";

    if (status > 0) {
      arg->fd = fd = find_connected_socket(fds_ary, &writefds);
      // 接続済みのソケットが見つかればこの時点でループから脱出
      // arg->fd に対象のソケットの fd が格納されている
      if (fd >= 0) { break; }
      status = -1; // no connected socket found
    }
    error = errno;
  }

  /* close unused fds */
  for (int i = 0; i < RARRAY_LEN(fds_ary); i++) {
    int _fd = FIX2INT(RARRAY_AREF(fds_ary, i));
    if (_fd != fd) { close(_fd); }
  }
  rb_ary_clear(fds_ary);

  // 接続済みのソケットが見つからないままアドレス在庫が枯渇した場合
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

  // ここまで到達した時点で arg->fd、fd には接続済みのソケットのfdが格納されている
  arg->fd = -1;
  // 接続済みのソケットのfdをブロッキングモードへ戻す
  socket_nonblock_set(fd, false);

  /* create new instance */
  return rsock_init_sock(arg->sock, fd);
}

// fd に O_NONBLOCK をセットする
static void
socket_nonblock_set(int fd, int nonblock)
{
  // fd のファイル状態フラグを読み出してflagsに格納
  int flags = fcntl(fd, F_GETFL);
  if (flags == -1) { rb_sys_fail(0); }

  if (nonblock) {
    // flags に O_NONBLOCK がセットされていることを確認
    //   セットされていればreturn
    //   そうでなければ flags に O_NONBLOCK をセット
    if ((flags & O_NONBLOCK) != 0) { return; }
    flags |= O_NONBLOCK;
  } else {
    if ((flags & O_NONBLOCK) == 0) { return; }
    flags &= ~O_NONBLOCK;
  }

  // O_NONBLOCK をセットした flags を fd にセット
  if (fcntl(fd, F_SETFL, flags) == -1) { rb_sys_fail(0); }
  return;
}

/*
 * @end is the absolute time when @ts is set to expire
 * Returns true if @end has past
 * Updates @ts and returns false otherwise
 */
static int
hrtime_update_expire(rb_hrtime_t *timeout, const rb_hrtime_t end)
{
  rb_hrtime_t now = rb_hrtime_now();
  if (now > end) return 1;
  *timeout = end - now;
  return 0;
}

static int
check_socket_error(const int fd) {
  int value;
  socklen_t len = (socklen_t)sizeof(value);
  getsockopt(fd, SOL_SOCKET, SO_ERROR, (void *)&value, &len);
  return value;
}

// 接続ソケットの fd を格納した配列から接続済みのソケットの fd を見つけて返す
static int
find_connected_socket(VALUE fds, rb_fdset_t *writefds) {
  for (int i = 0; i < RARRAY_LEN(fds); i++) {
    int fd = FIX2INT(RARRAY_AREF(fds, i));

    if (rb_fd_isset(fd, writefds)) {
      int error = check_socket_error(fd);

      switch (error) {
        case 0: // success
          return fd;
        case EINPROGRESS:
          break;
        default: // fail
          close(fd);
          errno = error;
          rb_ary_delete_at(fds, i);
          i--;
          break;
      }
    }
  }
  return -1;
}

static int
set_fds(const VALUE fds, rb_fdset_t *set) {
  // fds は接続済みもしくは接続中のソケットのfdの配列

  int nfds = 0;
  rb_fd_init(set);

  for (int i = 0; i < RARRAY_LEN(fds); i++) {
    // (include/ruby/internal/core/rarray.h)
    //   #define RARRAY_AREF(a, i) RARRAY_CONST_PTR(a)[i]
    // fds からソケットのfdを取り出す?
    int fd = FIX2INT(RARRAY_AREF(fds, i));
    if (fd > nfds) { nfds = fd; } // 監視対象のfdの最大値
    rb_fd_set(fd, set);
  }

  nfds++; // select(2) の第一引数。監視対象のfdの最大値に1を足した数値
  return nfds;
}

#endif // defined(F_SETFL) && defined(F_GETFL)

static void
getclockofday(struct timespec *ts)
{
#if defined(HAVE_CLOCK_GETTIME) && defined(CLOCK_MONOTONIC)
  if (clock_gettime(CLOCK_MONOTONIC, ts) == 0)
    return;
#endif
  rb_timespec_now(ts);
}

/*
 * Don't inline this, since library call is already time consuming
 * and we don't want "struct timespec" on stack too long for GC
 */
NOINLINE(rb_hrtime_t rb_hrtime_now(void));
rb_hrtime_t
rb_hrtime_now(void)
{
  struct timespec ts;

  getclockofday(&ts);
  return rb_timespec2hrtime(&ts);
}
```
