# 2024/2/8-10
- (参照先: `getaddrinfo/_impl09`)
- 接続中のソケットの待機をCRubyの内部APIからselect(2)へ置き換え
- select(2)のラッパー関数を`raddrinfo.c`から移動
- `writefds`を`wait_happy_eyeballs_fds`の中で待機できるように変更

#### TODO
- `cancel_happy_eyeballs_fds`に渡す引数のための構造体を定義し、必要な要素を渡す
- `cancel_happy_eyeballs_fds`に接続中のソケットのfdsをcloseする処理を追加し、メモリを解放する

```c
// ext/socket/ipsocket.c

// 追加
#ifndef HAPPY_EYEBALLS_INIT_INETSOCK_IMPL
#  if defined(HAVE_PTHREAD_CREATE) && defined(HAVE_PTHREAD_DETACH) && \
     !defined(__MINGW32__) && !defined(__MINGW64__) && \
     defined(F_SETFL) && defined(F_GETFL)
#    include "ruby/thread_native.h"
#    define HAPPY_EYEBALLS_INIT_INETSOCK_IMPL 1
#    define RESOLUTION_DELAY_USEC 50000 /* 50ms is a recommended value in RFC8305 */
#  else
#    define HAPPY_EYEBALLS_INIT_INETSOCK_IMPL 0
#  endif
#endif

enum sock_he_state {
    START,                /* Start to hostname resolution */
    V4W,                  /* Wait for Resolution Delay */
    V4C,                  /* Start to connect with IPv4 addrinfo */
    V6C,                  /* Start to connect with IPv4 addrinfo */
    V46C,                 /* Start to connect with IPv6 addrinfo or IPv4addrinfo */
    V46W,                 /* Wait for connecting with IPv6 addrinfo or IPv4addrinfo */
    SUCCESS,              /* Connection established */
    FAILURE,              /* Connection failed */
    TIMEOUT,              /* Connection timed out */
};

static void
socket_nonblock_set(int fd, int nonblock)
{
    int flags = fcntl(fd, F_GETFL);
    if (flags == -1) {
        rb_sys_fail(0);
    }

    if (nonblock) {
        if ((flags & O_NONBLOCK) != 0) {
            return;
        } else {
            flags |= O_NONBLOCK;
        }
    } else {
        if ((flags & O_NONBLOCK) == 0) {
            return;
        } else {
            flags &= ~O_NONBLOCK;
        }
    }

    if (fcntl(fd, F_SETFL, flags) == -1) {
        rb_sys_fail(0);
    }

    return;
}

static int
set_fds(const int *fds, int fds_size, fd_set *set)
{
    int nfds = 0;
    FD_ZERO(set);

    for (int i = 0; i < fds_size; i++) {
        int fd = fds[i];
        if (fd > nfds) {
            nfds = fd;
        }
        FD_SET(fd, set);
    }

    nfds++;
    return nfds;
}

static int
find_connected_socket(const int *fds, int fds_size, fd_set *writefds)
{
    for (int i = 0; i < fds_size; i++) {
        int fd = fds[i];

        if (fd < 0) continue;

        if (FD_ISSET(fd, writefds)) {
            int error;
            socklen_t len = sizeof(error);
            if (getsockopt(fd, SOL_SOCKET, SO_ERROR, &error, &len) == 0) {
                switch (error) {
                    case 0: // success
                        return fd;
                    case EINPROGRESS: // operation in progress
                        break;
                    default: // fail
                        errno = error;
                        close(fd);
                        i--;
                        break;
                }
            }
        }
    }
    return -1;
}

struct wait_happy_eyeballs_fds_arg
{
    int status;
    int *nfds;
    fd_set *readfds, *writefds;
    struct timeval *delay;
};

static void *
wait_happy_eyeballs_fds(void *ptr)
{
    // TODO 待機時間を受け取ることができるようにする
    struct wait_happy_eyeballs_fds_arg *arg = (struct wait_happy_eyeballs_fds_arg *)ptr;
    int status;
    status = select(*arg->nfds, arg->readfds, arg->writefds, NULL, arg->delay);
    arg->status = status;
    return 0;
}

struct cancel_happy_eyeballs_fds_arg
{
    int *cancelled;
    rb_nativethread_lock_t *lock;
    // TODO connecting_fdsのポインタを追加する
};

static void
cancel_happy_eyeballs_fds(void *ptr)
{
    // TODO
    //   名前解決の後始末:
    //     rb_getaddrinfo_happy_argを丸ごと受け取る必要はないので必要なものだけポインタで受け取る
    //     実際のリソース解放はスレッドの中でやる、ので基本的には今の処理の方向性を踏襲
    //   接続中のソケットの後始末:
    //     ここで配列の先頭からcloseし、メモリを解放する
    struct rb_getaddrinfo_happy_arg *arg = (struct rb_getaddrinfo_happy_arg *)ptr;
    rb_nativethread_lock_lock(&arg->lock);
    {
      arg->cancelled = 1;
    }
    rb_nativethread_lock_unlock(&arg->lock);
}

static VALUE
init_inetsock_internal_happy(VALUE v)
{
    struct inetsock_arg *arg = (void *)v;
    int last_error = 0;
    struct addrinfo *res = NULL;
    struct addrinfo *lres;
    int fd, status = 0, local = 0;
    // int family = AF_INET6; // TODO あとでAF_INETでも試す
    int family = AF_INET;
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

    // 引数を元にしてhintsに値を格納 (call_getaddrinfoに該当)
    // TODO アドレスファミリごとに用意する必要あり (hints.ai_familyが異なるため)
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
    hints.ai_flags |= additional_flags;

    // do_rb_getaddrinfo_happyに渡す引数の準備
    int pipefd[2];
    pipe(pipefd);
    int reader = pipefd[0];
    int writer = pipefd[1];
    rb_nativethread_lock_t lock;
    rb_nativethread_lock_initialize(&lock);

    struct rb_getaddrinfo_happy_arg *getaddrinfo_arg;
    getaddrinfo_arg = allocate_rb_getaddrinfo_happy_arg(hostp, portp, &hints); // TODO &外したい
    if (!getaddrinfo_arg) {
        return EAI_MEMORY;
    }

    getaddrinfo_arg->writer = writer;
    getaddrinfo_arg->lock = lock;

    int stop = 0;
    int need_free = 0;
    int state = START;
    pthread_t th;
    int *connecting_fds;
    int connecting_fds_size = 0;
    int capa = 10;
    connecting_fds = malloc(capa * sizeof(int));  // 動的に増やすための関数を用意する
    if (!connecting_fds) {
        perror("Failed to allocate memory");
        return -1;
    }
    fd_set readfds, writefds;
    int nfds;
    struct timeval resolution_delay;

    struct wait_happy_eyeballs_fds_arg wait_arg;
    wait_arg.readfds = &readfds;
    wait_arg.writefds = &writefds;
    wait_arg.nfds = &nfds;
    wait_arg.delay = NULL;

    while (!stop) {
        printf("\nstate %d\n", state);
        switch (state) {
        {
            case START:
                // getaddrinfoの実行
                if (do_pthread_create(&th, do_rb_getaddrinfo_happy, getaddrinfo_arg) != 0) {
                    free_rb_getaddrinfo_happy_arg(getaddrinfo_arg);
                    return EAI_AGAIN;
                }
                pthread_detach(th);

                // getaddrinfoの待機
                FD_ZERO(&readfds);
                FD_SET(reader, &readfds);
                nfds = reader + 1;
                rb_thread_call_without_gvl2(wait_happy_eyeballs_fds, &wait_arg, cancel_happy_eyeballs_fds, &getaddrinfo_arg);
                status = wait_arg.status;
                syscall = "select(2)";

                if (status < 0){
                    // selectの実行失敗。SystemCallError?
                    rsock_raise_resolution_error("rb_getaddrinfo_happy", EAI_SYSTEM);
                }
                else if (status == 0) {
                    // selectの返り値が0 = 時間切れの場合。いったんこのまま
                    return Qnil;
                }
                last_error = getaddrinfo_arg->err;
                if (last_error != 0) {
                    rb_nativethread_lock_lock(&lock);
                    {
                      if (--getaddrinfo_arg->refcount == 0) need_free = 1;
                    }
                    rb_nativethread_lock_unlock(&lock);
                    if (need_free) free_rb_getaddrinfo_happy_arg(getaddrinfo_arg);

                    rsock_raise_resolution_error("init_inetsock_internal_happy", last_error);
                }
                char result[4];
                read(reader, result, sizeof result);
                if (strncmp(result, HOSTNAME_RESOLUTION_PIPE_UPDATED, sizeof HOSTNAME_RESOLUTION_PIPE_UPDATED) != 0) {
                    // 何かしらのエラー
                    return Qnil;
                }

                struct rb_addrinfo *getaddrinfo_res = NULL;
                getaddrinfo_res = (struct rb_addrinfo *)xmalloc(sizeof(struct rb_addrinfo));
                getaddrinfo_res->allocated_by_malloc = 0;
                getaddrinfo_res->ai = getaddrinfo_arg->ai;

                arg->remote.res = getaddrinfo_res;
                arg->fd = fd = -1; // 初期化?
                res = arg->remote.res->ai;

                /*
                 * Maybe also accept a local address
                 */

                if (!NIL_P(arg->local.host) || !NIL_P(arg->local.serv)) {
                    arg->local.res = rsock_addrinfo(arg->local.host, arg->local.serv,
                                                    family, SOCK_STREAM, 0);
                }

                if (res->ai_family == AF_INET6) {
                    state = V6C;
                } else if (res->ai_family == AF_INET) {
                    state = V4W; // とりあえず
                }
                continue;
            }

            case V4W:
            {
                resolution_delay.tv_sec = 0;
                resolution_delay.tv_usec = RESOLUTION_DELAY_USEC;
                wait_arg.delay = &resolution_delay;
                FD_ZERO(&readfds);
                FD_SET(reader, &readfds);
                nfds = reader + 1;
                // TODO 第三・四引数
                rb_thread_call_without_gvl2(wait_happy_eyeballs_fds, &wait_arg, NULL, NULL);
                status = wait_arg.status;
                syscall = "select(2)";

                if (status == 0) {
                    state = V4C;
                } else {
                    // TODO (ref Socket.tcp)
                    // family_name, res = hostname_resolution_queue.get
                    // selectable_addrinfos.add(family_name, res) unless res.is_a? Exception
                    state = V46C;
                }
                continue;
            }

            case V6C:
            case V4C:
            case V46C:
            {
                #if !defined(INET6) && defined(AF_INET6) // TODO 必要?
                if (res->ai_family == AF_INET6)
                    arg->fd = fd = -1; // これはなに
                    res = res->ai_next;
                    if (res == NULL) {
                        state = FAILURE;
                    } else {
                        state = V46C;
                    }
                    continue;
                #endif
                lres = NULL;
                if (arg->local.res) {
                    for (lres = arg->local.res->ai; lres; lres = lres->ai_next) {
                        if (lres->ai_family == res->ai_family)
                            break;
                    }
                    if (!lres) { // 見つからなかった
                        if (res->ai_next || status < 0) { // 他のリモートアドレスファミリを試す
                            arg->fd = fd = -1; // これはなに
                            res = res->ai_next;
                            state = V46C;
                            continue;
                        } else {
                            /* Use a different family local address if no choice, this
                             * will cause EAFNOSUPPORT. */
                            lres = arg->local.res->ai;
                        }
                    }
                }
                status = rsock_socket(res->ai_family,res->ai_socktype,res->ai_protocol);
                syscall = "socket(2)";
                fd = status;
                if (fd < 0) { // socket(2)に失敗
                    last_error = errno;
                    arg->fd = fd = -1; // これはなに
                    res = res->ai_next;
                    if (res == NULL) {
                        state = FAILURE;
                    } else {
                        state = V46C;
                    }
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
                    socket_nonblock_set(fd, true);
                    status = connect(fd, res->ai_addr, res->ai_addrlen);
                    syscall = "connect(2)";
                }

                if (status < 0 && errno != EINPROGRESS) {
                    last_error = errno;
                    // TODO ここでcloseせず、SUCCESS、FAILURE、TIMEOUTでまとめてcloseできるようにする
                    close(fd);
                    arg->fd = fd = -1;
                    res = res->ai_next;
                    if (res == NULL) {
                        state = FAILURE;
                    } else {
                        state = V46C;
                    }
                } else if (status == 0) { // 接続に成功
                    state = SUCCESS;
                } else { // 接続中
                    connecting_fds[connecting_fds_size++] = fd;
                    state = V46W;
                }
                continue;
            }

            case V46W:
            {
                FD_ZERO(&readfds);
                FD_SET(reader, &readfds);
                wait_arg.delay = NULL; // TODO Connection Attempt Delay
                nfds = set_fds(connecting_fds, connecting_fds_size, &writefds);
                // TODO 第三・四引数
                rb_thread_call_without_gvl2(wait_happy_eyeballs_fds, &wait_arg, NULL, NULL);
                status = wait_arg.status;
                syscall = "select(2)";

                if (status >= 0) {
                    arg->fd = fd = find_connected_socket(connecting_fds, connecting_fds_size, &writefds);
                    if (fd >= 0) {
                        state = SUCCESS;
                    } else {
                        last_error = errno;
                        res = res->ai_next;
                        if (res == NULL) {
                            state = FAILURE;
                        } else {
                            state = V46C;
                        }
                    }
                } else {
                    last_error = errno;
                    // TODO ここでcloseせず、SUCCESS、FAILURE、TIMEOUTでまとめてcloseできるようにする
                    close(fd);
                    arg->fd = fd = -1;
                    res = res->ai_next;
                    if (res == NULL) {
                        state = FAILURE;
                    } else {
                        state = V46C;
                    }
                }
                continue;
            }

            case SUCCESS:
                stop = 1;
                continue;

            case FAILURE:
            {
                VALUE host, port;

                if (local < 0) {
                    // TODO ローカルアドレスのbindに失敗した時用。複数試す場合は最後のlocalを保存するようにする必要あり
                    host = arg->local.host;
                    port = arg->local.serv;
                } else {
                    host = arg->remote.host;
                    port = arg->remote.serv;
                }

                rsock_syserr_fail_host_port(last_error, syscall, host, port);
            }

            case TIMEOUT:
            {
                VALUE errno_module = rb_const_get(rb_cObject, rb_intern("Errno"));
                VALUE etimedout_error = rb_const_get(errno_module, rb_intern("ETIMEDOUT"));
                rb_raise(etimedout_error, "user specified timeout");
            }
        }
    }

    // 後処理
    rb_nativethread_lock_lock(&lock);
    {
        if (--getaddrinfo_arg->refcount == 0) need_free = 1;
    }
    rb_nativethread_lock_unlock(&lock);
    if (need_free) free_rb_getaddrinfo_happy_arg(getaddrinfo_arg);
    free(connecting_fds);

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

struct rb_getaddrinfo_happy_arg *allocate_rb_getaddrinfo_happy_arg(const char *hostp, const char *portp, const struct addrinfo *hints);

int do_pthread_create(pthread_t *th, void *(*start_routine) (void *), void *arg);
void * do_rb_getaddrinfo_happy(void *ptr);
void free_rb_getaddrinfo_happy_arg(struct rb_getaddrinfo_happy_arg *arg);
// -------------------------
```