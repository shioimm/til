# 実装

```
diff --git a/ext/socket/ipsocket.c b/ext/socket/ipsocket.c
index da42fbd27b..cd00c120bb 100644
--- a/ext/socket/ipsocket.c
+++ b/ext/socket/ipsocket.c
@@ -54,11 +54,13 @@ init_inetsock_internal(VALUE v)
     int status = 0, local = 0;
     int family = AF_UNSPEC;
     const char *syscall = 0;
+    VALUE resolv_timeout = arg->resolv_timeout;
     VALUE connect_timeout = arg->connect_timeout;

+    unsigned int t = rsock_value_timeout_to_msec(resolv_timeout);
     arg->remote.res = rsock_addrinfo(arg->remote.host, arg->remote.serv,
                                      family, SOCK_STREAM,
-                                     (type == INET_SERVER) ? AI_PASSIVE : 0);
+                                     (type == INET_SERVER) ? AI_PASSIVE : 0, t);


     /*
@@ -67,7 +69,7 @@ init_inetsock_internal(VALUE v)

     if (type != INET_SERVER && (!NIL_P(arg->local.host) || !NIL_P(arg->local.serv))) {
         arg->local.res = rsock_addrinfo(arg->local.host, arg->local.serv,
-                                        family, SOCK_STREAM, 0);
+                                        family, SOCK_STREAM, 0, 0);
     }

     VALUE io = Qnil;
@@ -557,12 +559,14 @@ init_fast_fallback_inetsock_internal(VALUE v)
         arg->getaddrinfo_shared = NULL;

         int family = arg->families[0];
+        unsigned int t = rsock_value_timeout_to_msec(resolv_timeout);
         arg->remote.res = rsock_addrinfo(
             arg->remote.host,
             arg->remote.serv,
             family,
             SOCK_STREAM,
-            0
+            0,
+            t
         );

         if (family == AF_INET6) {
@@ -1237,6 +1241,7 @@ rsock_init_inetsock(VALUE self, VALUE remote_host, VALUE remote_serv, VALUE loca
                     local_serv,
                     AF_UNSPEC,
                     SOCK_STREAM,
+                    0,
                     0
                 );

@@ -1492,7 +1497,7 @@ static VALUE
 ip_s_getaddress(VALUE obj, VALUE host)
 {
     union_sockaddr addr;
-    struct rb_addrinfo *res = rsock_addrinfo(host, Qnil, AF_UNSPEC, SOCK_STREAM, 0);
+    struct rb_addrinfo *res = rsock_addrinfo(host, Qnil, AF_UNSPEC, SOCK_STREAM, 0, 0);
     socklen_t len = res->ai->ai_addrlen;

     /* just take the first one */
diff --git a/ext/socket/raddrinfo.c b/ext/socket/raddrinfo.c
index fa98cc9c80..789d08ad37 100644
--- a/ext/socket/raddrinfo.c
+++ b/ext/socket/raddrinfo.c
@@ -293,10 +293,22 @@ rb_freeaddrinfo(struct rb_addrinfo *ai)
     xfree(ai);
 }

+unsigned int
+rsock_value_timeout_to_msec(VALUE timeout)
+{
+    double seconds = NUM2DBL(timeout);
+    if (seconds < 0) rb_raise(rb_eArgError, "timeout must not be negative");
+
+    double msec = seconds * 1000.0;
+    if (msec > UINT_MAX) rb_raise(rb_eArgError, "timeout too large");
+
+    return (unsigned int)(msec + 0.5);
+}
+
 #if GETADDRINFO_IMPL == 0

 static int
-rb_getaddrinfo(const char *hostp, const char *portp, const struct addrinfo *hints, struct addrinfo **ai)
+rb_getaddrinfo(const char *hostp, const char *portp, const struct addrinfo *hints, struct addrinfo **ai, unsigned int _timeout)
 {
     return getaddrinfo(hostp, portp, hints, ai);
 }
@@ -334,7 +346,7 @@ fork_safe_getaddrinfo(void *arg)
 }

 static int
-rb_getaddrinfo(const char *hostp, const char *portp, const struct addrinfo *hints, struct addrinfo **ai)
+rb_getaddrinfo(const char *hostp, const char *portp, const struct addrinfo *hints, struct addrinfo **ai, unsigned int _timeout)
 {
     struct getaddrinfo_arg arg;
     MEMZERO(&arg, struct getaddrinfo_arg, 1);
@@ -352,13 +364,14 @@ struct getaddrinfo_arg
     char *node, *service;
     struct addrinfo hints;
     struct addrinfo *ai;
-    int err, gai_errno, refcount, done, cancelled;
+    int err, gai_errno, refcount, done, cancelled, timedout;
     rb_nativethread_lock_t lock;
     rb_nativethread_cond_t cond;
+    unsigned int timeout;
 };

 static struct getaddrinfo_arg *
-allocate_getaddrinfo_arg(const char *hostp, const char *portp, const struct addrinfo *hints)
+allocate_getaddrinfo_arg(const char *hostp, const char *portp, const struct addrinfo *hints, unsigned int timeout)
 {
     size_t hostp_offset = sizeof(struct getaddrinfo_arg);
     size_t portp_offset = hostp_offset + (hostp ? strlen(hostp) + 1 : 0);
@@ -392,7 +405,8 @@ allocate_getaddrinfo_arg(const char *hostp, const char *portp, const struct addr
     arg->ai = NULL;

     arg->refcount = 2;
-    arg->done = arg->cancelled = 0;
+    arg->done = arg->cancelled = arg->timedout = 0;
+    arg->timeout = timeout;

     rb_nativethread_lock_initialize(&arg->lock);
     rb_native_cond_initialize(&arg->cond);
@@ -451,7 +465,16 @@ wait_getaddrinfo(void *ptr)
     struct getaddrinfo_arg *arg = (struct getaddrinfo_arg *)ptr;
     rb_nativethread_lock_lock(&arg->lock);
     while (!arg->done && !arg->cancelled) {
-        rb_native_cond_wait(&arg->cond, &arg->lock);
+        unsigned long msec = arg->timeout;
+        if (msec > 0) {
+            rb_native_cond_timedwait(&arg->cond, &arg->lock, msec);
+            if (!arg->done) {
+                arg->cancelled = 1;
+                arg->timedout = 1;
+            }
+        } else {
+            rb_native_cond_wait(&arg->cond, &arg->lock);
+        }
     }
     rb_nativethread_lock_unlock(&arg->lock);
     return 0;
@@ -490,7 +513,7 @@ fork_safe_do_getaddrinfo(void *ptr)
 }

 static int
-rb_getaddrinfo(const char *hostp, const char *portp, const struct addrinfo *hints, struct addrinfo **ai)
+rb_getaddrinfo(const char *hostp, const char *portp, const struct addrinfo *hints, struct addrinfo **ai, unsigned int timeout)
 {
     int retry;
     struct getaddrinfo_arg *arg;
@@ -499,7 +522,7 @@ rb_getaddrinfo(const char *hostp, const char *portp, const struct addrinfo *hint
 start:
     retry = 0;

-    arg = allocate_getaddrinfo_arg(hostp, portp, hints);
+    arg = allocate_getaddrinfo_arg(hostp, portp, hints, timeout);
     if (!arg) {
         return EAI_MEMORY;
     }
@@ -538,6 +561,12 @@ start:

     if (need_free) free_getaddrinfo_arg(arg);

+    if (arg->timedout) {
+        VALUE errno_module = rb_const_get(rb_cObject, rb_intern("Errno"));
+        VALUE etimedout_error = rb_const_get(errno_module, rb_intern("ETIMEDOUT"));
+        rb_raise(etimedout_error, "user specified timeout");
+    }
+
     // If the current thread is interrupted by asynchronous exception, the following raises the exception.
     // But if the current thread is interrupted by timer thread, the following returns; we need to manually retry.
     rb_thread_check_ints();
@@ -941,7 +970,7 @@ rb_scheduler_getaddrinfo(VALUE scheduler, VALUE host, const char *service,
 }

 struct rb_addrinfo*
-rsock_getaddrinfo(VALUE host, VALUE port, struct addrinfo *hints, int socktype_hack)
+rsock_getaddrinfo(VALUE host, VALUE port, struct addrinfo *hints, int socktype_hack, unsigned int timeout)
 {
     struct rb_addrinfo* res = NULL;
     struct addrinfo *ai;
@@ -976,7 +1005,7 @@ rsock_getaddrinfo(VALUE host, VALUE port, struct addrinfo *hints, int socktype_h
         }

         if (!resolved) {
-            error = rb_getaddrinfo(hostp, portp, hints, &ai);
+            error = rb_getaddrinfo(hostp, portp, hints, &ai, timeout);
             if (error == 0) {
                 res = (struct rb_addrinfo *)xmalloc(sizeof(struct rb_addrinfo));
                 res->allocated_by_malloc = 0;
@@ -1009,7 +1038,7 @@ rsock_fd_family(int fd)
 }

 struct rb_addrinfo*
-rsock_addrinfo(VALUE host, VALUE port, int family, int socktype, int flags)
+rsock_addrinfo(VALUE host, VALUE port, int family, int socktype, int flags, unsigned int timeout)
 {
     struct addrinfo hints;

@@ -1017,7 +1046,7 @@ rsock_addrinfo(VALUE host, VALUE port, int family, int socktype, int flags)
     hints.ai_family = family;
     hints.ai_socktype = socktype;
     hints.ai_flags = flags;
-    return rsock_getaddrinfo(host, port, &hints, 1);
+    return rsock_getaddrinfo(host, port, &hints, 1, timeout);
 }

 VALUE
@@ -1300,7 +1329,8 @@ call_getaddrinfo(VALUE node, VALUE service,
         hints.ai_flags = NUM2INT(flags);
     }

-    res = rsock_getaddrinfo(node, service, &hints, socktype_hack);
+    unsigned int t = rsock_value_timeout_to_msec(timeout);
+    res = rsock_getaddrinfo(node, service, &hints, socktype_hack, t);

     if (res == NULL)
         rb_raise(rb_eSocket, "host not found");
diff --git a/ext/socket/rubysocket.h b/ext/socket/rubysocket.h
index dcafbe24e3..e2daa1b326 100644
--- a/ext/socket/rubysocket.h
+++ b/ext/socket/rubysocket.h
@@ -327,8 +327,8 @@ void rb_freeaddrinfo(struct rb_addrinfo *ai);
 VALUE rsock_freeaddrinfo(VALUE arg);
 int rb_getnameinfo(const struct sockaddr *sa, socklen_t salen, char *host, size_t hostlen, char *serv, size_t servlen, int flags);
 int rsock_fd_family(int fd);
-struct rb_addrinfo *rsock_addrinfo(VALUE host, VALUE port, int family, int socktype, int flags);
-struct rb_addrinfo *rsock_getaddrinfo(VALUE host, VALUE port, struct addrinfo *hints, int socktype_hack);
+struct rb_addrinfo *rsock_addrinfo(VALUE host, VALUE port, int family, int socktype, int flags, unsigned int timeout);
+struct rb_addrinfo *rsock_getaddrinfo(VALUE host, VALUE port, struct addrinfo *hints, int socktype_hack, unsigned int timeout);

 VALUE rsock_fd_socket_addrinfo(int fd, struct sockaddr *addr, socklen_t len);
 VALUE rsock_io_socket_addrinfo(VALUE io, struct sockaddr *addr, socklen_t len);
@@ -453,6 +453,8 @@ void free_fast_fallback_getaddrinfo_shared(struct fast_fallback_getaddrinfo_shar
 #  endif
 #endif

+unsigned int rsock_value_timeout_to_msec(VALUE);
+
 void rsock_init_basicsocket(void);
 void rsock_init_ipsocket(void);
 void rsock_init_tcpsocket(void);
diff --git a/ext/socket/socket.c b/ext/socket/socket.c
index 8f593ca0bd..26bf0bae8c 100644
--- a/ext/socket/socket.c
+++ b/ext/socket/socket.c
@@ -965,7 +965,7 @@ sock_s_gethostbyname(VALUE obj, VALUE host)
 {
     rb_warn("Socket.gethostbyname is deprecated; use Addrinfo.getaddrinfo instead.");
     struct rb_addrinfo *res =
-        rsock_addrinfo(host, Qnil, AF_UNSPEC, SOCK_STREAM, AI_CANONNAME);
+        rsock_addrinfo(host, Qnil, AF_UNSPEC, SOCK_STREAM, AI_CANONNAME, 0);
     return rsock_make_hostent(host, res, sock_sockaddr);
 }

@@ -1183,7 +1183,7 @@ sock_s_getaddrinfo(int argc, VALUE *argv, VALUE _)
         norevlookup = rsock_do_not_reverse_lookup;
     }

-    res = rsock_getaddrinfo(host, port, &hints, 0);
+    res = rsock_getaddrinfo(host, port, &hints, 0, 0);

     ret = make_addrinfo(res, norevlookup);
     rb_freeaddrinfo(res);
@@ -1279,7 +1279,7 @@ sock_s_getnameinfo(int argc, VALUE *argv, VALUE _)
         hints.ai_socktype = (fl & NI_DGRAM) ? SOCK_DGRAM : SOCK_STREAM;
         /* af */
         hints.ai_family = NIL_P(af) ? PF_UNSPEC : rsock_family_arg(af);
-        res = rsock_getaddrinfo(host, port, &hints, 0);
+        res = rsock_getaddrinfo(host, port, &hints, 0, 0);
         sap = res->ai->ai_addr;
         salen = res->ai->ai_addrlen;
     }
@@ -1335,7 +1335,7 @@ sock_s_getnameinfo(int argc, VALUE *argv, VALUE _)
 static VALUE
 sock_s_pack_sockaddr_in(VALUE self, VALUE port, VALUE host)
 {
-    struct rb_addrinfo *res = rsock_addrinfo(host, port, AF_UNSPEC, 0, 0);
+    struct rb_addrinfo *res = rsock_addrinfo(host, port, AF_UNSPEC, 0, 0, 0);
     VALUE addr = rb_str_new((char*)res->ai->ai_addr, res->ai->ai_addrlen);

     rb_freeaddrinfo(res);
diff --git a/ext/socket/tcpsocket.c b/ext/socket/tcpsocket.c
index 28527f632f..0467bcfd89 100644
--- a/ext/socket/tcpsocket.c
+++ b/ext/socket/tcpsocket.c
@@ -109,7 +109,7 @@ tcp_s_gethostbyname(VALUE obj, VALUE host)
 {
     rb_warn("TCPSocket.gethostbyname is deprecated; use Addrinfo.getaddrinfo instead.");
     struct rb_addrinfo *res =
-        rsock_addrinfo(host, Qnil, AF_UNSPEC, SOCK_STREAM, AI_CANONNAME);
+        rsock_addrinfo(host, Qnil, AF_UNSPEC, SOCK_STREAM, AI_CANONNAME, 0);
     return rsock_make_hostent(host, res, tcp_sockaddr);
 }

diff --git a/ext/socket/udpsocket.c b/ext/socket/udpsocket.c
index a984933c9f..5538f24523 100644
--- a/ext/socket/udpsocket.c
+++ b/ext/socket/udpsocket.c
@@ -84,7 +84,7 @@ udp_connect(VALUE self, VALUE host, VALUE port)
 {
     struct udp_arg arg = {.io = self};

-    arg.res = rsock_addrinfo(host, port, rsock_fd_family(rb_io_descriptor(self)), SOCK_DGRAM, 0);
+    arg.res = rsock_addrinfo(host, port, rsock_fd_family(rb_io_descriptor(self)), SOCK_DGRAM, 0, 0);

     int result = (int)rb_ensure(udp_connect_internal, (VALUE)&arg, rsock_freeaddrinfo, (VALUE)arg.res);
     if (!result) {
@@ -129,7 +129,7 @@ udp_bind(VALUE self, VALUE host, VALUE port)
 {
     struct udp_arg arg = {.io = self};

-    arg.res = rsock_addrinfo(host, port, rsock_fd_family(rb_io_descriptor(self)), SOCK_DGRAM, 0);
+    arg.res = rsock_addrinfo(host, port, rsock_fd_family(rb_io_descriptor(self)), SOCK_DGRAM, 0, 0);

     VALUE result = rb_ensure(udp_bind_internal, (VALUE)&arg, rsock_freeaddrinfo, (VALUE)arg.res);
     if (!result) {
@@ -212,7 +212,7 @@ udp_send(int argc, VALUE *argv, VALUE sock)
     GetOpenFile(sock, arg.fptr);
     arg.sarg.fd = arg.fptr->fd;
     arg.sarg.flags = NUM2INT(flags);
-    arg.res = rsock_addrinfo(host, port, rsock_fd_family(arg.fptr->fd), SOCK_DGRAM, 0);
+    arg.res = rsock_addrinfo(host, port, rsock_fd_family(arg.fptr->fd), SOCK_DGRAM, 0, 0);
     ret = rb_ensure(udp_send_internal, (VALUE)&arg,
                     rsock_freeaddrinfo, (VALUE)arg.res);
     if (!ret) rsock_sys_fail_host_port("sendto(2)", host, port);

commit 365317f6baa375a07ee11ad585d8c4ec55b46fcb (upstream/master, origin/master, origin/HEAD, master)
Author: John Hawthorn <john@hawthorn.email>
Date:   Fri Jul 4 12:10:45 2025 -0700

    Fix wrong GENIV WB on too_complex Ractor traversal

        WBCHECK ERROR: Missed write barrier detected!
          Parent object: 0x7c4a5f1f66c0 (wb_protected: true)
            rb_obj_info_dump: 0x00007c4a5f1f66c0 T_IMEMO/<fields>
          Reference counts - snapshot: 2, writebarrier: 0, current: 2, missed: 1
          Missing reference to: 0x7b6a5f2f7010
            rb_obj_info_dump: 0x00007b6a5f2f7010 T_ARRAY/Array [E ] len: 1 (embed)
+    arg.res = rsock_addrinfo(host, port, rsock_fd_family(rb_io_descriptor(self)), SOCK_DGRAM, 0, 0);

     int result = (int)rb_ensure(udp_connect_internal, (VALUE)&arg, rsock_freeaddrinfo, (VALUE)arg.res);
     if (!result) {
@@ -129,7 +129,7 @@ udp_bind(VALUE self, VALUE host, VALUE port)
 {
     struct udp_arg arg = {.io = self};

-    arg.res = rsock_addrinfo(host, port, rsock_fd_family(rb_io_descriptor(self)), SOCK_DGRAM, 0);
+    arg.res = rsock_addrinfo(host, port, rsock_fd_family(rb_io_descriptor(self)), SOCK_DGRAM, 0, 0);

     VALUE result = rb_ensure(udp_bind_internal, (VALUE)&arg, rsock_freeaddrinfo, (VALUE)arg.res);
     if (!result) {
@@ -212,7 +212,7 @@ udp_send(int argc, VALUE *argv, VALUE sock)
     GetOpenFile(sock, arg.fptr);
     arg.sarg.fd = arg.fptr->fd;
     arg.sarg.flags = NUM2INT(flags);
-    arg.res = rsock_addrinfo(host, port, rsock_fd_family(arg.fptr->fd), SOCK_DGRAM, 0);
+    arg.res = rsock_addrinfo(host, port, rsock_fd_family(arg.fptr->fd), SOCK_DGRAM, 0, 0);
     ret = rb_ensure(udp_send_internal, (VALUE)&arg,
                     rsock_freeaddrinfo, (VALUE)arg.res);
     if (!ret) rsock_sys_fail_host_port("sendto(2)", host, port);
```
