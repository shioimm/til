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
  //       // (ext/socket/rubysocket.h)
  //       //   struct rb_addrinfo {
  //       //     struct addrinfo *ai;
  //       //     int allocated_by_malloc;
  //       //   };
  //     } remote, local;
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
  rb_fdset_t writefds; // 書き込みが可能かどうかを監視するFD群
  VALUE fds_ary = rb_ary_tmp_new(1); // VALUE rb_ary_hidden_new(long capa)
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

  // ----------
  // アドレス解決
  // ----------
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

  arg->fd = fd = -1; // ???

  // -------------
  // 接続試行 (初回)
  // -------------
  // addrinfo を順に試行する
  for (res = arg->remote.res->ai; res; res = res->ai_next) {

    #if !defined(INET6) && defined(AF_INET6)
    // ホストがIPv6に対応していない場合、かつ ai_family がIPv6の場合はスキップ
    if (res->ai_family == AF_INET6) {
      continue;
    }
    #endif

    lres = NULL;

    // TCPServer.new実行時、引数にlocal_hostやlocal_servが指定されている場合
    if (arg->local.res) {
      // 現在試行しているリモートアドレスaddrinfoの ai_family と同じ ai_family のローカルアドレスaddrinfoをlresに格納
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

    // rsock_socket() (ext/socket/init.c) は socket() を呼び出してそのソケットのfdを返す関数
    // 失敗時は-1を返し、errnoに値を設定する
    status = rsock_socket(res->ai_family,res->ai_socktype,res->ai_protocol);
    syscall = "socket(2)";
    fd = status;

    // socket() 失敗時は次のループへスキップ
    if (fd < 0) {
      error = errno;
      continue;
    }

    // 作成したソケットのfd
    arg->fd = fd;

    // 作成したソケットをノンブロッキングモードにする
    socket_nonblock_set(fd, true);

    // local_hostやlocal_servが指定されており、ローカルアドレスが取得できた場合は
    // 取得したアドレスのaddrinfoと作成したソケットをbind
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
    // 注) rsock_connect()じゃない
    if (status >= 0) {
      // fdがノンブロッキングモードなのでブロックしない
      status = connect(fd, res->ai_addr, res->ai_addrlen);
      // statusは0 (成功) か -1 (失敗)
      syscall = "connect(2)";
    }

    // connect(2) の実行結果が失敗であり、かつ発生したエラーが EINPROGRESS (接続試行中) 以外の場合
    if (status < 0 && errno != EINPROGRESS) {
      // ソケットを閉じて次のループへスキップ
      error = errno;
      close(fd);
      // arg->fdも失敗ステータスを格納 (-1)
      arg->fd = fd = -1;
      continue;
    } else { // connect() で接続できた場合もしくは EINPROGRESS の場合
      // fds_ary = rb_ary_tmp_new(1) ループの中で作成したソケットのfdが格納される
      // fds_ary << 接続済みもしくは接続中のソケットのfd
      rb_ary_push(fds_ary, INT2FIX(fd));

      // fds_ary の fd を writefds にセットしている
      nfds = set_fds(fds_ary, &writefds); // nfds は監視対象のfdの最大値
      // ここまで
      //   nfds     = select(2)の第一引数になる値
      //   writefds = 監視対象のfd群
      //   fd       = 接続済みもしくは接続中のソケットのfd
      //   arg->fd  = 接続済みもしくは接続中のソケットのfd

      // onnection Attempt Delayタイマー時間をセット
      /* connection_attempt_delay may be modified by select(2) in linux */
      connection_attempt_delay.tv_sec = 0;
      connection_attempt_delay.tv_usec = CONNECTION_ATTEMPT_DELAY_USEC;

      // 監視対象のfd群に対して select(2) を呼び出す、Connection Attempt Delayをタイムアウト値として設定
      // statusはselect(2)の返り値と同じ (更新されたFDの数か、0 (タイムアウト) か、-1 (エラー))
      status = rb_thread_fd_select(nfds, NULL, &writefds, NULL, &connection_attempt_delay);
      syscall = "select(2)";

      // 書き込み可能になったfdがある場合、もしくはタイムアウトした場合
      // タイムアウトの場合は速やかに次のループに入った方がいいんじゃないかなあ
      if (status >= 0) {
        arg->fd = fd = find_connected_socket(fds_ary, &writefds);
        // 接続済みのソケットが見つかればこの時点でループから脱出
        // arg->fdとfdに対象のソケットの fd もしくは-1 (エラー) が格納される
        if (fd >= 0) { break; } // 接続済みのソケットが見つかった場合はbreak
        status = -1; // no connected socket found
      }

      error = errno; // ここまでの処理で発生していたエラーを保存
    }
  }

  // ------------------
  // 接続試行 (二周目以降)
  // ------------------
  // addrinfoが枯渇するかaddrinfoループの中で接続完了したソケットがある場合は以降には到達しない
  // 在庫がある限り接続試行を開始して在庫が枯渇したらあとは接続を待つ方のループに入る、という戦略
  // (ただし初回の接続試行中に前のループで試行開始したfdが書き込み可能になっている可能性はあり)

  /* wait connection */
  // addrinfoループの find_connected_socket() が最終的に-1を返している (接続済みのソケットが見つからなかった) 場合
  // 既に接続済みソケットが見つかっている場合はここは飛ばして後処理に入る
  while (fd < 0 && RARRAY_LEN(fds_ary) > 0) { // fds_ary はfind_connected_socket()内で減る可能性あり
    struct timeval tv_storage, *tv = NULL;

    if (limit) { // if timeout is specified
      // connect_timeoutでタイムアウトした場合
      if (hrtime_update_expire(limit, end)) { // check if timeout has expired and update timeout
        status = -1;
        error = ETIMEDOUT;
        break;
      }
      // connect_timeoutのタイムアウト値を設定
      rb_hrtime2timeval(&tv_storage, limit); // set new timeout
      tv = &tv_storage;
    }

    // fds_ary の fd を writefds にセット
    // fds_ary は接続済みもしくは接続中のソケットのfdの配列
    // writefds は書き込み可能か監視対象のfd群
    nfds = set_fds(fds_ary, &writefds);

    // 監視対象のfd群に対して select(2) を呼び出す、connect_timeoutがある場合はtvをタイムアウト値として設定
    // statusはselect(2)の返り値と同じ (更新されたFDの数か、0 (タイムアウト) か、-1 (エラー))
    status = rb_thread_fd_select(nfds, NULL, &writefds, NULL, tv);
    syscall = "select(2)";

    // 書き込み可能になったfdがある場合
    if (status > 0) {
      arg->fd = fd = find_connected_socket(fds_ary, &writefds);
      // 接続済みのソケットが見つかればこの時点でループから脱出
      // arg->fdとfdに対象のソケットの fd もしくは-1 (エラー) が格納される
      if (fd >= 0) { break; }
      status = -1; // no connected socket found
    }
    // ここまでで発生したエラーをerrorに保存
    error = errno;
  }

  /* close unused fds */
  // 接続に成功している場合、arg->fd = fd には接続済みのソケットのfdが格納されている
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
  arg->fd = -1; // ???
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
  // フラグの読み出しに失敗した場合
  if (flags == -1) { rb_sys_fail(0); }

  if (nonblock) { // socket_nonblock_set(<fd>, true); の場合
    // flags に O_NONBLOCK がセットされていることを確認
    //   セットされていればreturn
    //   そうでなければ flags に O_NONBLOCK をセット
    if ((flags & O_NONBLOCK) != 0) { return; }
    flags |= O_NONBLOCK;
  } else { // socket_nonblock_set(<fd>, false); の場合
    // flags に O_NONBLOCK がセットされていないことを確認
    //   セットされていなければreturn
    //   そうでなければ flags から O_NONBLOCK を削除
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

// fdの保留中のエラーを取得して返す
static int
check_socket_error(const int fd) {
  int value; // 取得したエラーの内容を格納する
  socklen_t len = (socklen_t)sizeof(value);
  getsockopt(fd, SOL_SOCKET, SO_ERROR, (void *)&value, &len);
  return value;
}

// 接続ソケットの fd を格納した配列から接続済みのソケットの fd を見つけて返す
// 初回の接続試行) 書き込み可能になったfdがある場合、もしくはタイムアウトした場合に呼ばれる
// 二回目以降の接続試行) 書き込み可能になったfdがある場合に呼ばれる
static int
find_connected_socket(VALUE fds, rb_fdset_t *writefds) {
  for (int i = 0; i < RARRAY_LEN(fds); i++) {
    // fds からソケットのfdを取り出している?
    int fd = FIX2INT(RARRAY_AREF(fds, i));

    // writefdsの中にfdが含まれている場合
    if (rb_fd_isset(fd, writefds)) {
      // 当該fdに保留中のエラーを取得
      int error = check_socket_error(fd);

      switch (error) {
        case 0: // success
          return fd;
        case EINPROGRESS:
          // このソケットはまだ接続中。
          // ほかに接続済みのソケットがいるかもしれないけど一旦breakしている
          // あるいはタイムアウトでこの関数が呼ばれた場合もここ
          break;
        default: // fail
          // いろいろクリアする必要あり
          close(fd); // fdを閉じる
          errno = error; // エラーを保存する
          rb_ary_delete_at(fds, i); // fdsから該当のfdを削除
          i--; // インデックスを巻き戻す
          break;
      }
    }
  }
  return -1;
}

// setに監視対象のfdを追加し、select(2)の第一引数になる値を返す
static int
set_fds(const VALUE fds, rb_fdset_t *set) {
  // fds は接続済みもしくは接続中のソケットのfdの配列
  // set は書き込み可能か監視対象のfd群

  int nfds = 0; // select(2) の第一引数になる値。<監視対象のfdの最大値 + 1>の値
  rb_fd_init(set);

  for (int i = 0; i < RARRAY_LEN(fds); i++) {
    // (include/ruby/internal/core/rarray.h)
    //   #define RARRAY_AREF(a, i) RARRAY_CONST_PTR(a)[i]
    // fds からソケットのfdを取り出している?
    int fd = FIX2INT(RARRAY_AREF(fds, i));
    if (fd > nfds) { nfds = fd; } // 監視対象のfdの最大値をnfdsにセット
    rb_fd_set(fd, set); // 現在の監視対象のfd群に接続済みもしくは接続中のソケットのfdを追加
  }

  nfds++; // 監視対象のfdの最大値に1を足してselect(2) の第一引数にできるようにする。
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

## TL;DR (`init_inetsock_internal_happy()`)
1. `AF_UNSPEC`をアドレス解決対象のファミリとしてaddrinfoを取得する
2. 一連のaddrinfoで順に接続試行を行う 
    - ソケットを作成
    - 作成したソケットをノンブロッキングモードに設定
    - connect(2)を呼び出す
    - 接続完了した場合もしくは接続中の場合:
      - 対象のfdを接続済み・接続中のfdの配列に格納
      - select(2)を呼び出し、接続の完了もしくはConnection Attempt Delayを待機
      - 書き込み可能になったfdがある場合、もしくはタイムアウトした場合:
        - 接続済みのソケットのfdを取得
          - 接続済みのソケットが見つかった場合:
            - ループから脱出
          - 接続済みのソケットが見つからなかった場合:
            - 次のループへスキップ (addrinfoが枯渇するまで)
    - 接続に失敗した場合:
      - 作成したソケットを閉じて次のループへスキップ
3. addrinfoループを抜けた時点で接続済みのソケットが見つからなかった場合、
   接続中のfdの配列の長さ分のループを開始
   - 接続中のfdの配列に対して select(2) を呼び出す
    - 書き込み可能になったfdがある場合:
      - 接続試行の対象fd群をループして各ソケットの接続状態を順に確認
        - 接続済みのソケットが見つかった場合:
          - 接続済みのソケットのfdを取得
        - 接続進行中のソケットが見つかった場合:
          - 接続確認ループを脱出 (次の接続試行ループに入る…他に接続済みのソケットがある場合はどうなるんだろう)
        - 接続失敗したソケットが見つかった場合
          - 接続試行の対象fd群から対象のソケットのfdを削除
    - 書き込み可能になったfdがない場合:
      - `connect_timeout`まで待って接続できなかった場合`error = ETIMEDOUT`でループを抜ける
      - `connect_timeout`がない場合は接続できるまで待機し続ける
4. 後処理