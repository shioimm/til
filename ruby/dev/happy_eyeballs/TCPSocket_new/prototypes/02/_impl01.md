# 2024/1/16、1/23
- `getaddrinfo/_impl07`を使用
- 諸々引数の準備
- スレッドを作成してその中で`do_rb_getaddrinfo_happy`を実行
- 名前解決を待機し、解決できたaddrinfoを取得

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

#ifdef HAVE_CONST_AI_ADDRCONFIG
    remote_addrinfo_hints |= AI_ADDRCONFIG;
#endif

    // HEv2 ----------------------------------------------
    struct addrinfo *getaddrinfo_ai;
    int getaddrinfo_error = 0;

    // 引数を元にしてhintsに値を格納 (call_getaddrinfoに該当)
    struct addrinfo hints;
    MEMZERO(&hints, struct addrinfo, 1);
    hints.ai_family = family;
    hints.ai_socktype = SOCK_STREAM;
    hints.ai_protocol = IPPROTO_TCP;
    hints.ai_flags = remote_addrinfo_hints;

    // getaddrinfoを実行するための準備 (rsock_getaddrinfoに該当)
    char *hostp, *portp;
    char hbuf[NI_MAXHOST], pbuf[NI_MAXSERV];
    int additional_flags = 0;
    hostp = host_str(arg->remote.host, hbuf, sizeof(hbuf), &additional_flags);
    portp = port_str(arg->remote.serv, pbuf, sizeof(pbuf), &additional_flags);

    // do_rb_getaddrinfo_happyに渡す引数の準備
    int pipefd[2];
    pipe(pipefd);
    rb_nativethread_lock_t lock;
    rb_nativethread_lock_initialize(&lock);

    struct rb_getaddrinfo_happy_arg *getaddrinfo_arg;
    getaddrinfo_arg = allocate_rb_getaddrinfo_happy_arg(hostp, portp, &hints); // TODO &外したい
    if (!getaddrinfo_arg) {
        return EAI_MEMORY;
    }

    getaddrinfo_arg->writer = pipefd[1];
    getaddrinfo_arg->lock = lock;

    // getaddrinfoの実行
    pthread_t th;
    if (do_pthread_create(&th, do_rb_getaddrinfo_happy, getaddrinfo_arg) != 0) {
        free_rb_getaddrinfo_happy_arg(getaddrinfo_arg);
        return EAI_AGAIN;
    }
    pthread_detach(th);

    // getaddrinfoの待機
    int retval;
    fd_set rfds;
    FD_ZERO(&rfds);
    FD_SET(pipefd[0], &rfds);
    struct wait_rb_getaddrinfo_happy_arg wait_arg;
    wait_arg.rfds = &rfds;
    wait_arg.reader = pipefd[0];
    rb_thread_call_without_gvl2(wait_rb_getaddrinfo_happy, &wait_arg, cancel_rb_getaddrinfo_happy, &getaddrinfo_arg);

    retval = wait_arg.retval;
    int need_free = 0;

    if (retval < 0){
        // selectの実行失敗。SystemCallError?
        rsock_raise_resolution_error("rb_getaddrinfo_happy_main", EAI_SYSTEM);
    }
    else if (retval > 0){
        getaddrinfo_error = getaddrinfo_arg->err;
        if (getaddrinfo_error == 0) {
            getaddrinfo_ai = getaddrinfo_arg->ai;
            char result[4];
            read(pipefd[0], result, sizeof result);
            if (strncmp(result, HOSTNAME_RESOLUTION_PIPE_UPDATED, sizeof HOSTNAME_RESOLUTION_PIPE_UPDATED) == 0) {
              printf("\nHostname resolurion finished\n");

              // 動作確認のため取得したaddrinfoからRubyオブジェクトを作成
              struct rb_addrinfo *getaddrinfo_res;
              getaddrinfo_res = (struct rb_addrinfo *)xmalloc(sizeof(struct rb_addrinfo));
              getaddrinfo_res->allocated_by_malloc = 0;
              getaddrinfo_res->ai = getaddrinfo_ai;
              struct addrinfo *r;
              for (r = getaddrinfo_res->ai; r; r = r->ai_next) {
                  printf("r->ai_addr %p\n", r->ai_addr);
              }

              // 後処理
              rb_freeaddrinfo(getaddrinfo_res);
              rb_nativethread_lock_lock(&lock);
              {
                if (--getaddrinfo_arg->refcount == 0) need_free = 1;
              }
              rb_nativethread_lock_unlock(&lock);
              if (need_free) free_rb_getaddrinfo_happy_arg(getaddrinfo_arg);
            }
            else {
              rb_nativethread_lock_lock(&lock);
              {
                if (--getaddrinfo_arg->refcount == 0) need_free = 1;
              }
              rb_nativethread_lock_unlock(&lock);
              if (need_free) free_rb_getaddrinfo_happy_arg(getaddrinfo_arg);

              rsock_raise_resolution_error("init_inetsock_internal_happy", error);
            }
        }
        else {
          // selectの返り値が0 = 時間切れの場合。いったんこのまま
        }
    }
    // ---------------------------------------------------

    arg->remote.res = rsock_addrinfo(arg->remote.host, arg->remote.serv,
                                     family, SOCK_STREAM, remote_addrinfo_hints);

    /*
     * Maybe also accept a local address
     */

    if (!NIL_P(arg->local.host) || !NIL_P(arg->local.serv)) {
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
                                   false, tv);
            syscall = "connect(2)";
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

```c
// ext/socket/rubysocket.h

// 追加 -------------------
#define HOSTNAME_RESOLUTION_PIPE_UPDATED "1"

char *host_str(VALUE host, char *hbuf, size_t hbuflen, int *flags_ptr);
char *port_str(VALUE port, char *pbuf, size_t pbuflen, int *flags_ptr);

struct rb_getaddrinfo_happy_arg
{
    char *node, *service;
    struct addrinfo hints;
    struct addrinfo *ai;
    int err, refcount, cancelled;
    int writer;
    rb_nativethread_lock_t lock;
};

struct wait_rb_getaddrinfo_happy_arg
{
    int reader;
    int retval;
    fd_set *rfds;
};

struct rb_getaddrinfo_happy_arg *allocate_rb_getaddrinfo_happy_arg(const char *hostp, const char *portp, const struct addrinfo *hints);

int do_pthread_create(pthread_t *th, void *(*start_routine) (void *), void *arg);
void * do_rb_getaddrinfo_happy(void *ptr);
void free_rb_getaddrinfo_happy_arg(struct rb_getaddrinfo_happy_arg *arg);
void * wait_rb_getaddrinfo_happy(void *ptr);
void cancel_rb_getaddrinfo_happy(void *ptr);
// -------------------------
```
