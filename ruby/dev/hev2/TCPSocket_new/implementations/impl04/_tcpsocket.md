# 11/23-

```c
// ext/socket/tcpsocket.c

static VALUE
tcp_init(int argc, VALUE *argv, VALUE sock)
{
    VALUE remote_host, remote_serv;
    VALUE local_host, local_serv;
    VALUE opt;
    static ID keyword_ids[4];
    VALUE kwargs[4];
    VALUE resolv_timeout = Qnil;
    VALUE connect_timeout = Qnil;
    VALUE fast_fallback = Qnil;
    VALUE test_mode_settings = Qnil;
    if (!keyword_ids[0]) {
        CONST_ID(keyword_ids[0], "resolv_timeout");
        CONST_ID(keyword_ids[1], "connect_timeout");
        CONST_ID(keyword_ids[2], "fast_fallback");
        CONST_ID(keyword_ids[3], "test_mode_settings");
    }
    rb_scan_args(argc, argv, "22:", &remote_host, &remote_serv,
                        &local_host, &local_serv, &opt);
    if (!NIL_P(opt)) {
        rb_get_kwargs(opt, keyword_ids, 0, 4, kwargs);
        if (kwargs[0] != Qundef) { resolv_timeout = kwargs[0]; }
        if (kwargs[1] != Qundef) { connect_timeout = kwargs[1]; }
        if (kwargs[2] != Qundef) { fast_fallback = kwargs[2]; }
        if (kwargs[3] != Qundef) { test_mode_settings = kwargs[3]; }
    }

    if (fast_fallback == Qnil) {
        fast_fallback = rb_ivar_get(rb_cSocket, tcp_fast_fallback);
        if (fast_fallback == Qnil) fast_fallback = Qtrue;
    }

    return rsock_init_inetsock(sock, remote_host, remote_serv,
                               local_host, local_serv, INET_CLIENT,
                               resolv_timeout, connect_timeout, fast_fallback,
                               test_mode_settings);
}
```
