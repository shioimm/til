`open_timeout-TCPSocket_new`
- TODO `init_inetsock_internal`に`open_timeout`を実装する
- `connect_timeout`のdocがなんかおかしいので直す(別PR)

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
    arg.open_timeout = open_timeout;
    return rb_ensure(init_inetsock_internal, (VALUE)&arg,
                     inetsock_cleanup, (VALUE)&arg);
}

#elif FAST_FALLBACK_INIT_INETSOCK_IMPL == 1

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

#endif

static struct timeval *
select_expires_at(
    struct hostname_resolution_store *resolution_store,
    struct timeval *resolution_delay,
    struct timeval *connection_attempt_delay,
    struct timeval *user_specified_resolv_timeout_at,
    struct timeval *user_specified_connect_timeout_at,
    struct timeval *user_specified_open_timeout_at
) {
    if (any_addrinfos(resolution_store)) {
        struct timeval *delay;
        delay = resolution_delay ? resolution_delay : connection_attempt_delay;

        if (user_specified_open_timeout_at &&
            timercmp(user_specified_open_timeout_at, delay, <)) {
            return user_specified_open_timeout_at;
        }
        return delay;
    }

    if (user_specified_open_timeout_at) return user_specified_open_timeout_at;
    // ...
}

static VALUE
init_fast_fallback_inetsock_internal(VALUE v)
{
    // ...
    VALUE resolv_timeout = arg->resolv_timeout;
    VALUE connect_timeout = arg->connect_timeout;
    VALUE open_timeout = arg->open_timeout;
    // ...
    struct timeval user_specified_resolv_timeout_storage;
    struct timeval *user_specified_resolv_timeout_at = NULL;
    struct timeval user_specified_connect_timeout_storage;
    struct timeval *user_specified_connect_timeout_at = NULL;
    struct timeval user_specified_open_timeout_storage;
    struct timeval *user_specified_open_timeout_at = NULL;
    struct timespec now = current_clocktime_ts();

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
            user_specified_open_timeout_at
        );
        // ...

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
current_clocktime()
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
    VALUE open_timeout = arg->open_timeout;

    VALUE timeout = NIL_P(open_timeout) ? resolv_timeout : open_timeout;
    VALUE starts_at = current_clocktime();

    // TODO rsock_addrinfoにtimeoutを渡せるようにする
    arg->remote.res = rsock_addrinfo(arg->remote.host, arg->remote.serv,
                                     family, SOCK_STREAM,
                                     (type == INET_SERVER) ? AI_PASSIVE : 0);

    // ...
    for (res = arg->remote.res->ai; res; res = res->ai_next) {
        // ...
        if (type == INET_SERVER) {
            // ...
        } else {
            if (NIL_P(open_timeout)) {
                timeout = connect_timeout;
            } else {
                VALUE elapsed = rb_funcall(current_clocktime(), '-', 1, starts_at);
                timeout = rb_funcall(open_timeout, '-', 1, elapsed);
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

#### diff

```
diff --git a/ext/socket/ipsocket.c b/ext/socket/ipsocket.c
index da42fbd27b..d5f1a57b6e 100644
--- a/ext/socket/ipsocket.c
+++ b/ext/socket/ipsocket.c
@@ -23,6 +23,7 @@ struct inetsock_arg
     int type;
     VALUE resolv_timeout;
     VALUE connect_timeout;
+    VALUE open_timeout;
 };

 static VALUE
@@ -44,6 +45,13 @@ inetsock_cleanup(VALUE v)
     return Qnil;
 }

+static VALUE
+current_clocktime()
+{
+    VALUE clock_monotnic_const = rb_const_get(rb_mProcess, rb_intern("CLOCK_MONOTONIC"));
+    return rb_funcall(rb_mProcess, rb_intern("clock_gettime"), 1, clock_monotnic_const);
+}
+
 static VALUE
 init_inetsock_internal(VALUE v)
 {
@@ -54,8 +62,14 @@ init_inetsock_internal(VALUE v)
     int status = 0, local = 0;
     int family = AF_UNSPEC;
     const char *syscall = 0;
+    VALUE resolv_timeout = arg->resolv_timeout;
     VALUE connect_timeout = arg->connect_timeout;
+    VALUE open_timeout = arg->open_timeout;

+    VALUE timeout = NIL_P(open_timeout) ? resolv_timeout : open_timeout;
+    VALUE starts_at = current_clocktime();
+
+    // TODO rsock_addrinfoにtimeoutを渡せるようにする
     arg->remote.res = rsock_addrinfo(arg->remote.host, arg->remote.serv,
                                      family, SOCK_STREAM,
                                      (type == INET_SERVER) ? AI_PASSIVE : 0);
@@ -122,8 +136,15 @@ init_inetsock_internal(VALUE v)
                 syscall = "bind(2)";
             }

+            if (NIL_P(open_timeout)) {
+                timeout = connect_timeout;
+            } else {
+                VALUE elapsed = rb_funcall(current_clocktime(), '-', 1, starts_at);
+                timeout = rb_funcall(open_timeout, '-', 1, elapsed);
+            }
+
             if (status >= 0) {
-                status = rsock_connect(io, res->ai_addr, res->ai_addrlen, (type == INET_SOCKS), connect_timeout);
+                status = rsock_connect(io, res->ai_addr, res->ai_addrlen, (type == INET_SOCKS), timeout);
                 syscall = "connect(2)";
             }
         }
@@ -172,8 +193,12 @@ init_inetsock_internal(VALUE v)
 #if FAST_FALLBACK_INIT_INETSOCK_IMPL == 0

 VALUE
-rsock_init_inetsock(VALUE self, VALUE remote_host, VALUE remote_serv, VALUE local_host, VALUE local_serv, int type, VALUE resolv_timeout, VALUE connect_timeout, VALUE _fast_fallback, VALUE _test_mode_settings)
-{
+rsock_init_inetsock(
+    VALUE self, VALUE remote_host, VALUE remote_serv,
+    VALUE local_host, VALUE local_serv, int type,
+    VALUE resolv_timeout, VALUE connect_timeout, VALUE open_timeout,
+    VALUE _fast_fallback, VALUE _test_mode_settings
+) {
     struct inetsock_arg arg;
     arg.self = self;
     arg.io = Qnil;
@@ -186,6 +211,7 @@ rsock_init_inetsock(VALUE self, VALUE remote_host, VALUE remote_serv, VALUE loca
     arg.type = type;
     arg.resolv_timeout = resolv_timeout;
     arg.connect_timeout = connect_timeout;
+    arg.open_timeout = open_timeout;
     return rb_ensure(init_inetsock_internal, (VALUE)&arg,
                      inetsock_cleanup, (VALUE)&arg);
 }
@@ -221,6 +247,7 @@ struct fast_fallback_inetsock_arg
     int type;
     VALUE resolv_timeout;
     VALUE connect_timeout;
+    VALUE open_timeout;

     const char *hostp, *portp;
     int *families;
@@ -380,12 +407,22 @@ select_expires_at(
     struct timeval *resolution_delay,
     struct timeval *connection_attempt_delay,
     struct timeval *user_specified_resolv_timeout_at,
-    struct timeval *user_specified_connect_timeout_at
+    struct timeval *user_specified_connect_timeout_at,
+    struct timeval *user_specified_open_timeout_at
 ) {
     if (any_addrinfos(resolution_store)) {
-        return resolution_delay ? resolution_delay : connection_attempt_delay;
+        struct timeval *delay;
+        delay = resolution_delay ? resolution_delay : connection_attempt_delay;
+
+        if (user_specified_open_timeout_at &&
+            timercmp(user_specified_open_timeout_at, delay, <)) {
+            return user_specified_open_timeout_at;
+        }
+        return delay;
     }

+    if (user_specified_open_timeout_at) return user_specified_open_timeout_at;
+
     struct timeval *timeout = NULL;

     if (user_specified_resolv_timeout_at) {
@@ -503,6 +540,7 @@ init_fast_fallback_inetsock_internal(VALUE v)
     VALUE io = arg->io;
     VALUE resolv_timeout = arg->resolv_timeout;
     VALUE connect_timeout = arg->connect_timeout;
+    VALUE open_timeout = arg->open_timeout;
     VALUE test_mode_settings = arg->test_mode_settings;
     struct addrinfo *remote_ai = NULL, *local_ai = NULL;
     int connected_fd = -1, status = 0, local_status = 0;
@@ -549,8 +587,16 @@ init_fast_fallback_inetsock_internal(VALUE v)
     struct timeval *user_specified_resolv_timeout_at = NULL;
     struct timeval user_specified_connect_timeout_storage;
     struct timeval *user_specified_connect_timeout_at = NULL;
+    struct timeval user_specified_open_timeout_storage;
+    struct timeval *user_specified_open_timeout_at = NULL;
     struct timespec now = current_clocktime_ts();

+    if (!NIL_P(open_timeout)) {
+        struct timeval open_timeout_tv = rb_time_interval(open_timeout);
+        user_specified_open_timeout_storage = add_ts_to_tv(open_timeout_tv, now);
+        user_specified_open_timeout_at = &user_specified_open_timeout_storage;
+    }
+
     /* start of hostname resolution */
     if (arg->family_size == 1) {
         arg->wait = -1;
@@ -848,7 +894,8 @@ init_fast_fallback_inetsock_internal(VALUE v)
             resolution_delay_expires_at,
             connection_attempt_delay_expires_at,
             user_specified_resolv_timeout_at,
-            user_specified_connect_timeout_at
+            user_specified_connect_timeout_at,
+            user_specified_open_timeout_at
         );
         if (ends_at) {
             delay = tv_to_timeout(ends_at, now);
@@ -1101,6 +1148,12 @@ init_fast_fallback_inetsock_internal(VALUE v)
             }
         }

+        if (is_timeout_tv(user_specified_open_timeout_at, now)) {
+            VALUE errno_module = rb_const_get(rb_cObject, rb_intern("Errno"));
+            VALUE etimedout_error = rb_const_get(errno_module, rb_intern("ETIMEDOUT"));
+            rb_raise(etimedout_error, "user specified timeout");
+        }
+
         if (!any_addrinfos(&resolution_store)) {
             if (!in_progress_fds(arg->connection_attempt_fds_size) &&
                 resolution_store.is_all_finished) {
@@ -1214,8 +1267,16 @@ fast_fallback_inetsock_cleanup(VALUE v)
 }

 VALUE
-rsock_init_inetsock(VALUE self, VALUE remote_host, VALUE remote_serv, VALUE local_host, VALUE local_serv, int type, VALUE resolv_timeout, VALUE connect_timeout, VALUE fast_fallback, VALUE test_mode_settings)
-{
+rsock_init_inetsock(
+    VALUE self, VALUE remote_host, VALUE remote_serv,
+    VALUE local_host, VALUE local_serv, int type,
+    VALUE resolv_timeout, VALUE connect_timeout, VALUE open_timeout,
+    VALUE fast_fallback, VALUE test_mode_settings
+) {
+    if (!NIL_P(open_timeout) && (!NIL_P(resolv_timeout) || !NIL_P(connect_timeout))) {
+        rb_raise(rb_eArgError, "Cannot specify open_timeout along with connect_timeout or resolv_timeout");
+    }
+
     if (type == INET_CLIENT && FAST_FALLBACK_INIT_INETSOCK_IMPL == 1 && RTEST(fast_fallback)) {
         struct rb_addrinfo *local_res = NULL;
         char *hostp, *portp;
@@ -1271,6 +1332,7 @@ rsock_init_inetsock(VALUE self, VALUE remote_host, VALUE remote_serv, VALUE loca
             fast_fallback_arg.type = type;
             fast_fallback_arg.resolv_timeout = resolv_timeout;
             fast_fallback_arg.connect_timeout = connect_timeout;
+            fast_fallback_arg.open_timeout = open_timeout;
             fast_fallback_arg.hostp = hostp;
             fast_fallback_arg.portp = portp;
             fast_fallback_arg.additional_flags = additional_flags;
@@ -1307,6 +1369,7 @@ rsock_init_inetsock(VALUE self, VALUE remote_host, VALUE remote_serv, VALUE loca
     arg.type = type;
     arg.resolv_timeout = resolv_timeout;
     arg.connect_timeout = connect_timeout;
+    arg.open_timeout = open_timeout;

     return rb_ensure(init_inetsock_internal, (VALUE)&arg,
                      inetsock_cleanup, (VALUE)&arg);
diff --git a/ext/socket/rubysocket.h b/ext/socket/rubysocket.h
index 54a5381da4..62d1c1899b 100644
--- a/ext/socket/rubysocket.h
+++ b/ext/socket/rubysocket.h
@@ -355,7 +355,7 @@ int rsock_socket(int domain, int type, int proto);
 int rsock_detect_cloexec(int fd);
 VALUE rsock_init_sock(VALUE sock, int fd);
 VALUE rsock_sock_s_socketpair(int argc, VALUE *argv, VALUE klass);
-VALUE rsock_init_inetsock(VALUE sock, VALUE remote_host, VALUE remote_serv, VALUE local_host, VALUE local_serv, int type, VALUE resolv_timeout, VALUE connect_timeout, VALUE fast_fallback, VALUE test_mode_settings);
+VALUE rsock_init_inetsock(VALUE sock, VALUE remote_host, VALUE remote_serv, VALUE local_host, VALUE local_serv, int type, VALUE resolv_timeout, VALUE connect_timeout, VALUE open_timeout, VALUE fast_fallback, VALUE test_mode_settings);
 VALUE rsock_init_unixsock(VALUE sock, VALUE path, int server);

 struct rsock_send_arg {
diff --git a/ext/socket/sockssocket.c b/ext/socket/sockssocket.c
index 1031812bef..10d87b07f6 100644
--- a/ext/socket/sockssocket.c
+++ b/ext/socket/sockssocket.c
@@ -34,7 +34,7 @@ socks_init(VALUE sock, VALUE host, VALUE port)
         init = 1;
     }

-    return rsock_init_inetsock(sock, host, port, Qnil, Qnil, INET_SOCKS, Qnil, Qnil, Qfalse, Qnil);
+    return rsock_init_inetsock(sock, host, port, Qnil, Qnil, INET_SOCKS, Qnil, Qnil, Qnil, Qfalse, Qnil);
 }

 #ifdef SOCKS5
diff --git a/ext/socket/tcpserver.c b/ext/socket/tcpserver.c
index 8206fe46a9..0069f3c703 100644
--- a/ext/socket/tcpserver.c
+++ b/ext/socket/tcpserver.c
@@ -36,7 +36,7 @@ tcp_svr_init(int argc, VALUE *argv, VALUE sock)
     VALUE hostname, port;

     rb_scan_args(argc, argv, "011", &hostname, &port);
-    return rsock_init_inetsock(sock, hostname, port, Qnil, Qnil, INET_SERVER, Qnil, Qnil, Qfalse, Qnil);
+    return rsock_init_inetsock(sock, hostname, port, Qnil, Qnil, INET_SERVER, Qnil, Qnil, Qnil, Qfalse, Qnil);
 }

 /*
diff --git a/ext/socket/tcpsocket.c b/ext/socket/tcpsocket.c
index 28527f632f..55c2c1787c 100644
--- a/ext/socket/tcpsocket.c
+++ b/ext/socket/tcpsocket.c
@@ -35,6 +35,7 @@
  *
  * [:resolv_timeout] Specifies the timeout in seconds from when the hostname resolution starts.
  * [:connect_timeout] This method sequentially attempts connecting to all candidate destination addresses.<br>The +connect_timeout+ specifies the timeout in seconds from the start of the connection attempt to the last candidate.<br>By default, all connection attempts continue until the timeout occurs.<br>When +fast_fallback:false+ is explicitly specified,<br>a timeout is set for each connection attempt and any connection attempt that exceeds its timeout will be canceled.
+ * [:open_timeout] Specifies the timeout in seconds from the start of the method execution.<br>If this timeout is reached while there are still addresses that have not yet been attempted for connection, no further attempts will be made.
  * [:fast_fallback] Enables the Happy Eyeballs Version 2 algorithm (enabled by default).
  */
 static VALUE
@@ -43,29 +44,32 @@ tcp_init(int argc, VALUE *argv, VALUE sock)
     VALUE remote_host, remote_serv;
     VALUE local_host, local_serv;
     VALUE opt;
-    static ID keyword_ids[4];
-    VALUE kwargs[4];
+    static ID keyword_ids[5];
+    VALUE kwargs[5];
     VALUE resolv_timeout = Qnil;
     VALUE connect_timeout = Qnil;
+    VALUE open_timeout = Qnil;
     VALUE fast_fallback = Qnil;
     VALUE test_mode_settings = Qnil;

     if (!keyword_ids[0]) {
         CONST_ID(keyword_ids[0], "resolv_timeout");
         CONST_ID(keyword_ids[1], "connect_timeout");
-        CONST_ID(keyword_ids[2], "fast_fallback");
-        CONST_ID(keyword_ids[3], "test_mode_settings");
+        CONST_ID(keyword_ids[2], "open_timeout");
+        CONST_ID(keyword_ids[3], "fast_fallback");
+        CONST_ID(keyword_ids[4], "test_mode_settings");
     }

     rb_scan_args(argc, argv, "22:", &remote_host, &remote_serv,
                         &local_host, &local_serv, &opt);

     if (!NIL_P(opt)) {
-        rb_get_kwargs(opt, keyword_ids, 0, 4, kwargs);
+        rb_get_kwargs(opt, keyword_ids, 0, 5, kwargs);
         if (kwargs[0] != Qundef) { resolv_timeout = kwargs[0]; }
         if (kwargs[1] != Qundef) { connect_timeout = kwargs[1]; }
-        if (kwargs[2] != Qundef) { fast_fallback = kwargs[2]; }
-        if (kwargs[3] != Qundef) { test_mode_settings = kwargs[3]; }
+        if (kwargs[2] != Qundef) { open_timeout = kwargs[2]; }
+        if (kwargs[3] != Qundef) { fast_fallback = kwargs[3]; }
+        if (kwargs[4] != Qundef) { test_mode_settings = kwargs[4]; }
     }

     if (fast_fallback == Qnil) {
@@ -75,8 +79,8 @@ tcp_init(int argc, VALUE *argv, VALUE sock)

     return rsock_init_inetsock(sock, remote_host, remote_serv,
                                local_host, local_serv, INET_CLIENT,
-                               resolv_timeout, connect_timeout, fast_fallback,
-                               test_mode_settings);
+                               resolv_timeout, connect_timeout, open_timeout,
+                               fast_fallback, test_mode_settings);
 }

 static VALUE
diff --git a/test/socket/test_tcp.rb b/test/socket/test_tcp.rb
index be6d59b31e..58fe44a279 100644
--- a/test/socket/test_tcp.rb
+++ b/test/socket/test_tcp.rb
@@ -73,6 +73,30 @@ def test_initialize_resolv_timeout
     end
   end

+  def test_tcp_initialize_open_timeout
+    return if RUBY_PLATFORM =~ /mswin|mingw|cygwin/
+
+    server = TCPServer.new("127.0.0.1", 0)
+    port = server.connect_address.ip_port
+    server.close
+
+    assert_raise(Errno::ETIMEDOUT) do
+      TCPSocket.new(
+        "localhost",
+        port,
+        open_timeout: 0.01,
+        fast_fallback: true,
+        test_mode_settings: { delay: { ipv4: 1000 } }
+      )
+    end
+  end
+
+  def test_initialize_open_timeout_with_other_timeouts
+    assert_raise(ArgumentError) do
+      TCPSocket.new("localhost", 12345, open_timeout: 0.01, resolv_timeout: 0.01)
+    end
+  end
+
   def test_initialize_connect_timeout
     assert_raise(IO::TimeoutError, Errno::ENETUNREACH, Errno::EACCES) do
       TCPSocket.new("192.0.2.1", 80, connect_timeout: 0)
```
