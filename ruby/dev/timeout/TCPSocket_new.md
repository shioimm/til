`open_timeout-TCPSocket_new`
- TODO `init_fast_fallback_inetsock_internal` / `init_inetsock_internal`に`open_timeout`を実装する

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
    VALUE open_timeout;
};

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
    VALUE open_timeout;

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

VALUE
rsock_init_inetsock(
    VALUE self, VALUE remote_host, VALUE remote_serv,
    VALUE local_host, VALUE local_serv, int type,
    VALUE resolv_timeout, VALUE connect_timeout, VALUE open_timeout,
    VALUE fast_fallback, VALUE test_mode_settings
) {
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
            fast_fallback_arg.open_timeout = open_timeout;
            // ...
            return rb_ensure(init_fast_fallback_inetsock_internal, (VALUE)&fast_fallback_arg,
                             fast_fallback_inetsock_cleanup, (VALUE)&fast_fallback_arg);
        }
    }

    struct inetsock_arg arg;
    arg.resolv_timeout = resolv_timeout;
    arg.connect_timeout = connect_timeout;
    arg.open_timeout = open_timeout;

    return rb_ensure(init_inetsock_internal, (VALUE)&arg,
                     inetsock_cleanup, (VALUE)&arg);

}

static VALUE
init_fast_fallback_inetsock_internal(VALUE v)
{
    // ...
}

static VALUE
init_inetsock_internal(VALUE v)
{
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
VALUE rsock_init_inetsock(VALUE sock, VALUE remote_host, VALUE remote_serv, VALUE local_host, VALUE local_serv, int type, VALUE resolv_timeout, VALUE connect_timeout, VALUE open_timout, VALUE fast_fallback, VALUE test_mode_settings);
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
    return rsock_init_inetsock(sock, hostname, port, Qnil, Qnil, INET_SERVER, Qnil, Qnil, Qnil, Qfalse, Qnil);
}
```

```c
// ext/socket/sockssocket.c

static VALUE
socks_init(VALUE sock, VALUE host, VALUE port)
{
    // ...
    return rsock_init_inetsock(sock, host, port, Qnil, Qnil, INET_SOCKS, Qnil, Qnil, Qnil, Qfalse, Qnil);
}
```
