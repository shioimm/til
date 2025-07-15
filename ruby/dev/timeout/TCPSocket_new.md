`open_timeout-TCPSocket_new`
- `init_fast_fallback_inetsock_internal`
  - `open_timeout`が指定されており、HEv2既定のタイムアウト値よりも`open_timeout`の方が小さい場合に
    `select_expires_at`が`open_timeout`を返すようにする。そうでない場合はHEv2既定のタイムアウト値を返す
  - `select(2)`から返ってきた時に`open_timeout`がタイムアウト済みならば例外を発生させる
- `init_inetsock_internal`
  - `open_timeout` (優先) もしくは`resolv_timeout`を使って`rsock_value_timeout_to_msec`を計算し、
    `rsock_addrinfo`にタイムアウト値を渡す。開始時間を記録しておく。
  - `rsock_addrinfo`から返ってきたら現在時刻から`rsock_addrinfo`の開始時間を引いた経過時間を計算する
  - `open_timeout`から経過時間を引いた時間をタイムアウト値として`rsock_connect`を実行する
    - `open_timeout`から経過時間を引いた時間がマイナスになっていたらその時点で例外を発生させる

```c
// ext/socket/ipsocket.c

struct inetsock_arg
{
    VALUE self;
    VALUE io;

    struct {
        VALUE host, serv;
        struct rb_addrinfo *res;
    } remote, local;
    int type;
    VALUE resolv_timeout;
    VALUE connect_timeout;
    VALUE open_timeout; // 追加
};

void
rsock_raise_user_specified_timeout() // 追加
{
    VALUE errno_module = rb_const_get(rb_cObject, rb_intern("Errno"));
    VALUE etimedout_error = rb_const_get(errno_module, rb_intern("ETIMEDOUT"));
    rb_raise(etimedout_error, "user specified timeout");
}

struct fast_fallback_inetsock_arg
{
    VALUE self;
    VALUE io;

    struct {
        VALUE host, serv;
        struct rb_addrinfo *res;
    } remote, local;
    int type;
    VALUE resolv_timeout;
    VALUE connect_timeout;
    VALUE open_timeout; // 追加

    const char *hostp, *portp;
    int *families;
    int family_size;
    int additional_flags;
    struct fast_fallback_getaddrinfo_entry *getaddrinfo_entries[2];
    struct fast_fallback_getaddrinfo_shared *getaddrinfo_shared;
    rb_fdset_t readfds, writefds;
    int wait;
    int connection_attempt_fds_size;
    int *connection_attempt_fds;
    VALUE test_mode_settings;
};

#if FAST_FALLBACK_INIT_INETSOCK_IMPL == 0

VALUE
rsock_init_inetsock(
    VALUE self, VALUE remote_host, VALUE remote_serv,
    VALUE local_host, VALUE local_serv, int type,
    VALUE resolv_timeout, VALUE connect_timeout, VALUE open_timeout,
    VALUE _fast_fallback, VALUE _test_mode_settings
) {
    struct inetsock_arg arg;
    arg.self = self;
    arg.io = Qnil;
    arg.remote.host = remote_host;
    arg.remote.serv = remote_serv;
    arg.remote.res = 0;
    arg.local.host = local_host;
    arg.local.serv = local_serv;
    arg.local.res = 0;
    arg.type = type;
    arg.resolv_timeout = resolv_timeout;
    arg.connect_timeout = connect_timeout;
    arg.open_timeout = open_timeout; // 追加
    return rb_ensure(init_inetsock_internal, (VALUE)&arg,
                     inetsock_cleanup, (VALUE)&arg);
}

#elif FAST_FALLBACK_INIT_INETSOCK_IMPL == 1

VALUE
rsock_init_inetsock(
    VALUE self, VALUE remote_host, VALUE remote_serv,
    VALUE local_host, VALUE local_serv, int type,
    VALUE resolv_timeout, VALUE connect_timeout, VALUE open_timeout, // open_timeout追加
    VALUE fast_fallback, VALUE test_mode_settings
) {
    // 追加
    if (!NIL_P(open_timeout) && (!NIL_P(resolv_timeout) || !NIL_P(connect_timeout))) {
        rb_raise(rb_eArgError, "Cannot specify open_timeout along with connect_timeout or resolv_timeout");
    }

    if (type == INET_CLIENT && FAST_FALLBACK_INIT_INETSOCK_IMPL == 1 && RTEST(fast_fallback)) {
        // ...
        if (!is_specified_ip_address(hostp)) {
            struct fast_fallback_inetsock_arg fast_fallback_arg;
            memset(&fast_fallback_arg, 0, sizeof(fast_fallback_arg));
            // ...
            fast_fallback_arg.resolv_timeout = resolv_timeout;
            fast_fallback_arg.connect_timeout = connect_timeout;
            fast_fallback_arg.open_timeout = open_timeout; // 追加
            // ...
            return rb_ensure(init_fast_fallback_inetsock_internal, (VALUE)&fast_fallback_arg,
                             fast_fallback_inetsock_cleanup, (VALUE)&fast_fallback_arg);
        }
    }

    struct inetsock_arg arg;
    arg.resolv_timeout = resolv_timeout;
    arg.connect_timeout = connect_timeout;
    arg.open_timeout = open_timeout; // 追加

    return rb_ensure(init_inetsock_internal, (VALUE)&arg,
                     inetsock_cleanup, (VALUE)&arg);

}

#endif

static struct timeval *
select_expires_at(
    struct hostname_resolution_store *resolution_store,
    struct timeval *resolution_delay,
    struct timeval *connection_attempt_delay,
    struct timeval *user_specified_resolv_timeout_at,
    struct timeval *user_specified_connect_timeout_at,
    struct timeval *user_specified_open_timeout_at // 追加
) {
    if (any_addrinfos(resolution_store)) { // 以下修正
        struct timeval *delay;
        delay = resolution_delay ? resolution_delay : connection_attempt_delay;

        if (user_specified_open_timeout_at &&
            timercmp(user_specified_open_timeout_at, delay, <)) {
            return user_specified_open_timeout_at;
        }
        return delay;
    }

    // 追加
    // アドレス在庫がない場合、常にopen_timeoutを優先して返す
    // 他のuser specified timeoutと同時に指定されることはないためここで早期returnしている
    if (user_specified_open_timeout_at) return user_specified_open_timeout_at;
    // ...
}

static VALUE
init_fast_fallback_inetsock_internal(VALUE v)
{
    // ...
    VALUE resolv_timeout = arg->resolv_timeout;
    VALUE connect_timeout = arg->connect_timeout;
    VALUE open_timeout = arg->open_timeout; // 追加
    // ...
    struct timeval user_specified_resolv_timeout_storage;
    struct timeval *user_specified_resolv_timeout_at = NULL;
    struct timeval user_specified_connect_timeout_storage;
    struct timeval *user_specified_connect_timeout_at = NULL;
    struct timeval user_specified_open_timeout_storage; // 追加
    struct timeval *user_specified_open_timeout_at = NULL; // 追加
    struct timespec now = current_clocktime_ts();

    // 追加
    if (!NIL_P(open_timeout)) {
        struct timeval open_timeout_tv = rb_time_interval(open_timeout);
        user_specified_open_timeout_storage = add_ts_to_tv(open_timeout_tv, now);
        user_specified_open_timeout_at = &user_specified_open_timeout_storage;
    }

    while (true) {
        // ...
        ends_at = select_expires_at(
            &resolution_store,
            resolution_delay_expires_at,
            connection_attempt_delay_expires_at,
            user_specified_resolv_timeout_at,
            user_specified_connect_timeout_at,
            user_specified_open_timeout_at // 追加
        );
        // ...

        // 追加
        if (is_timeout_tv(user_specified_open_timeout_at, now)) {
            VALUE errno_module = rb_const_get(rb_cObject, rb_intern("Errno"));
            VALUE etimedout_error = rb_const_get(errno_module, rb_intern("ETIMEDOUT"));
            rb_raise(etimedout_error, "user specified timeout");
        }

        if (!any_addrinfos(&resolution_store)) {
            // ...
        }
    }
    // ...
}

static VALUE
current_clocktime() // 追加
{
    VALUE clock_monotnic_const = rb_const_get(rb_mProcess, rb_intern("CLOCK_MONOTONIC"));
    return rb_funcall(rb_mProcess, rb_intern("clock_gettime"), 1, clock_monotnic_const);
}

static VALUE
init_inetsock_internal(VALUE v)
{
    // ...
    VALUE resolv_timeout = arg->resolv_timeout;
    VALUE connect_timeout = arg->connect_timeout;
    VALUE open_timeout = arg->open_timeout; // 追加
    VALUE timeout;
    VALUE starts_at;
    unsigned int timeout_msec;

    timeout = NIL_P(open_timeout) ? resolv_timeout : open_timeout;
    timeout_msec = NIL_P(timeout) ? 0 : rsock_value_timeout_to_msec(timeout);
    starts_at = current_clocktime();

    arg->remote.res = rsock_addrinfo(arg->remote.host, arg->remote.serv,
                                     family, SOCK_STREAM,
                                     (type == INET_SERVER) ? AI_PASSIVE : 0, timeout_msec);

    // ...
    for (res = arg->remote.res->ai; res; res = res->ai_next) {
        // ...
        if (type == INET_SERVER) {
            // ...
        } else {
            // 追加
            if (NIL_P(open_timeout)) {
                timeout = connect_timeout;
            } else {
                VALUE elapsed = rb_funcall(current_clocktime(), '-', 1, starts_at);
                timeout = rb_funcall(open_timeout, '-', 1, elapsed);
                if (rb_funcall(timeout, '<', 1, INT2FIX(0)) == Qtrue) rsock_raise_user_specified_timeout();
            }

            if (status >= 0) {
                status = rsock_connect(io, res->ai_addr, res->ai_addrlen, (type == INET_SOCKS), timeout);
                syscall = "connect(2)";
            }
         }
        // ...
    }
    // ...
}
```

```ruby
# test/socket/test_tcp.rb

def test_tcp_initialize_open_timeout
  TCPServer.open("localhost", 0) do |svr|
    th = Thread.new {
      c = svr.accept
      c.close
    }
    addr = svr.addr
    s = TCPSocket.new(addr[3], addr[1], open_timeout: 10)
    th.join
  ensure
    s.close()
  end
end

def test_initialize_open_timeout_with_other_timeouts
  assert_raise(ArgumentError) do
    TCPSocket.new("localhost", 12345, open_timeout: 0.01, resolv_timeout: 0.01)
  end
end
```

```c
// ext/socket/rubysocket.h
VALUE rsock_init_inetsock(
    VALUE self, VALUE remote_host, VALUE remote_serv,
    VALUE local_host, VALUE local_serv, int type,
    VALUE resolv_timeout, VALUE connect_timeout, VALUE open_timeout, // open_timeout を追加
    VALUE _fast_fallback, VALUE _test_mode_settings
)

void rsock_raise_user_specified_timeout(void);
```

```c
// ext/socket/tcpsocket.c
static VALUE
tcp_init(int argc, VALUE *argv, VALUE sock)
{
    // ...
    static ID keyword_ids[5];
    VALUE kwargs[5];
    VALUE resolv_timeout = Qnil;
    VALUE connect_timeout = Qnil;
    VALUE open_timeout = Qnil;
    // ...

    if (!keyword_ids[0]) {
        CONST_ID(keyword_ids[0], "resolv_timeout");
        CONST_ID(keyword_ids[1], "connect_timeout");
        CONST_ID(keyword_ids[2], "open_timeout");
        CONST_ID(keyword_ids[3], "fast_fallback");
        CONST_ID(keyword_ids[4], "test_mode_settings");
    }

    rb_scan_args(argc, argv, "22:", &remote_host, &remote_serv,
                        &local_host, &local_serv, &opt);

    if (!NIL_P(opt)) {
        rb_get_kwargs(opt, keyword_ids, 0, 5, kwargs);
        if (kwargs[0] != Qundef) { resolv_timeout = kwargs[0]; }
        if (kwargs[1] != Qundef) { connect_timeout = kwargs[1]; }
        if (kwargs[2] != Qundef) { open_timeout = kwargs[2]; }
        if (kwargs[3] != Qundef) { fast_fallback = kwargs[3]; }
        if (kwargs[4] != Qundef) { test_mode_settings = kwargs[4]; }
    }

    // ...
    return rsock_init_inetsock(sock, remote_host, remote_serv,
                               local_host, local_serv, INET_CLIENT,
                               resolv_timeout, connect_timeout, open_timeout,
                               fast_fallback, test_mode_settings);
}
```

```c
// ext/socket/tcpserver.c

static VALUE
tcp_svr_init(int argc, VALUE *argv, VALUE sock)
{
    // ...
    // 修正
    return rsock_init_inetsock(sock, hostname, port, Qnil, Qnil, INET_SERVER, Qnil, Qnil, Qnil, Qfalse, Qnil);
}
```

```c
// ext/socket/sockssocket.c

static VALUE
socks_init(VALUE sock, VALUE host, VALUE port)
{
    // ...
    // 修正
    return rsock_init_inetsock(sock, host, port, Qnil, Qnil, INET_SOCKS, Qnil, Qnil, Qnil, Qfalse, Qnil);
}
```
