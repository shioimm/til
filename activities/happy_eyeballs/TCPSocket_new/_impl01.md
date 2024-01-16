# 2024/1/15

```c
// ext/socket/ipsocket.c

// 追加
#ifndef HAPPY_EYEBALLS_INIT_INETSOCK_IMPL
#  if defined(HAVE_PTHREAD_CREATE) && defined(HAVE_PTHREAD_DETACH) && \
     !defined(__MINGW32__) && !defined(__MINGW64__) && \
     defined(F_SETFL) && defined(F_GETFL)
#    include "ruby/thread_native.h"
#    define HAPPY_EYEBALLS_INIT_INETSOCK_IMPL 1
#  else
#    define HAPPY_EYEBALLS_INIT_INETSOCK_IMPL 0
#  endif
#endif

static VALUE
init_inetsock_internal_happy(VALUE v)
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
    int remote_addrinfo_hints = 0;

    if (!NIL_P(connect_timeout)) {
        tv_storage = rb_time_interval(connect_timeout);
        tv = &tv_storage;
    }

    if (type == INET_SERVER) {
      remote_addrinfo_hints |= AI_PASSIVE;
    }
#ifdef HAVE_CONST_AI_ADDRCONFIG
    remote_addrinfo_hints |= AI_ADDRCONFIG;
#endif

    arg->remote.res = rsock_addrinfo(arg->remote.host, arg->remote.serv,
                                     family, SOCK_STREAM, remote_addrinfo_hints);


    /*
     * Maybe also accept a local address
     */

    if (type != INET_SERVER && (!NIL_P(arg->local.host) || !NIL_P(arg->local.serv))) {
        arg->local.res = rsock_addrinfo(arg->local.host, arg->local.serv,
                                        family, SOCK_STREAM, 0);
    }

    arg->fd = fd = -1;
    for (res = arg->remote.res->ai; res; res = res->ai_next) {
#if !defined(INET6) && defined(AF_INET6)
        if (res->ai_family == AF_INET6)
            continue;
#endif
        lres = NULL;
        if (arg->local.res) {
            for (lres = arg->local.res->ai; lres; lres = lres->ai_next) {
                if (lres->ai_family == res->ai_family)
                    break;
            }
            if (!lres) {
                if (res->ai_next || status < 0)
                    continue;
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
            setsockopt(fd, SOL_SOCKET, SO_REUSEADDR,
                       (char*)&status, (socklen_t)sizeof(status));
#endif
            status = bind(fd, res->ai_addr, res->ai_addrlen);
            syscall = "bind(2)";
        }
        else {
            if (lres) {
#if !defined(_WIN32) && !defined(__CYGWIN__)
                status = 1;
                setsockopt(fd, SOL_SOCKET, SO_REUSEADDR,
                           (char*)&status, (socklen_t)sizeof(status));
#endif
                status = bind(fd, lres->ai_addr, lres->ai_addrlen);
                local = status;
                syscall = "bind(2)";
            }

            if (status >= 0) {
                status = rsock_connect(fd, res->ai_addr, res->ai_addrlen,
                                       (type == INET_SOCKS), tv);
                syscall = "connect(2)";
            }
        }

        if (status < 0) {
            error = errno;
            close(fd);
            arg->fd = fd = -1;
            continue;
        } else
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

VALUE
rsock_init_inetsock(VALUE sock, VALUE remote_host, VALUE remote_serv,
                    VALUE local_host, VALUE local_serv, int type,
                    VALUE resolv_timeout, VALUE connect_timeout)
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

    if (type == INET_CLIENT && HAPPY_EYEBALLS_INIT_INETSOCK_IMPL) {
      return rb_ensure(init_inetsock_internal_happy, (VALUE)&arg,
                       inetsock_cleanup, (VALUE)&arg);
    } else {
      return rb_ensure(init_inetsock_internal, (VALUE)&arg,
                       inetsock_cleanup, (VALUE)&arg);
    }
}
```
