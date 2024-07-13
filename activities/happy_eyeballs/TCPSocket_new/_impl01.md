# prototype/02 時点
- (参照先: `getaddrinfo/_impl00`)

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
#    define CONNECTION_ATTEMPT_DELAY_NSEC 250000 /* 250ms is a recommended value in RFC8305 */
#    define IPV6_ENTRY_POS 0
#    define IPV4_ENTRY_POS 1
#  else
#    define HAPPY_EYEBALLS_INIT_INETSOCK_IMPL 0
#  endif
#endif

tatic struct rb_getaddrinfo_happy_shared *
create_rb_getaddrinfo_happy_shared()
{
    struct rb_getaddrinfo_happy_shared *shared;
    shared = (struct rb_getaddrinfo_happy_shared *)calloc(1, sizeof(struct rb_getaddrinfo_happy_shared));
    return shared;
}

static struct rb_getaddrinfo_happy_entry *
allocate_rb_getaddrinfo_happy_entry()
{
    struct rb_getaddrinfo_happy_entry *entry;
    entry = (struct rb_getaddrinfo_happy_entry *)calloc(1, sizeof(struct rb_getaddrinfo_happy_entry));
    return entry;
}

static void allocate_rb_getaddrinfo_happy_hints(struct addrinfo *hints, int family, int remote_addrinfo_hints, int additional_flags)
{
    MEMZERO(hints, struct addrinfo, 1);
    hints->ai_family = family;
    hints->ai_socktype = SOCK_STREAM;
    hints->ai_protocol = IPPROTO_TCP;
    hints->ai_flags = remote_addrinfo_hints;
    hints->ai_flags |= additional_flags;
}

struct wait_happy_eyeballs_fds_arg
{
    int status, nfds;
    fd_set readfds, writefds;
    struct timeval *delay;
};

static void *
wait_happy_eyeballs_fds(void *ptr)
{
    struct wait_happy_eyeballs_fds_arg *arg = (struct wait_happy_eyeballs_fds_arg *)ptr;
    int status;
    status = select(arg->nfds, &arg->readfds, &arg->writefds, NULL, arg->delay);
    arg->status = status;
    return 0;
}

static void
cancel_happy_eyeballs_fds(void *ptr)
{
    struct rb_getaddrinfo_happy_shared *arg = (struct rb_getaddrinfo_happy_shared *)ptr;

    rb_nativethread_lock_lock(arg->lock);
    {
        arg->cancelled = true;
        write(arg->notify, SELECT_CANCELLED, strlen(SELECT_CANCELLED));
    }
    rb_nativethread_lock_unlock(arg->lock);
}

static void
socket_nonblock_set(int fd)
{
    int flags = fcntl(fd, F_GETFL);

    if (flags == -1) rb_sys_fail(0);
    if ((flags & O_NONBLOCK) != 0) return;

    flags |= O_NONBLOCK;

    if (fcntl(fd, F_SETFL, flags) == -1) rb_sys_fail(0);
    return;
}

struct timespec current_clocktime_ts()
{
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return ts;
}

struct timespec add_timeval_to_timespec(struct timeval tv, struct timespec ts)
{
    long long nsec_total = ts.tv_nsec + (long long)tv.tv_usec * 1000;

    if (nsec_total >= 1000000000LL) {
        ts.tv_sec += nsec_total / 1000000000LL;
        ts.tv_nsec = nsec_total % 1000000000LL;
    } else {
        ts.tv_nsec = nsec_total;
    }

    ts.tv_sec += tv.tv_sec;
    return ts;
}

struct timespec resolv_timeout_expires_at_ts(struct timeval resolv_timeout)
{
    struct timespec ts = current_clocktime_ts();
    ts = add_timeval_to_timespec(resolv_timeout, ts);
    return ts;
}

struct timespec connection_attempt_delay_expires_at_ts()
{
    struct timespec ts = current_clocktime_ts();
    ts.tv_nsec += CONNECTION_ATTEMPT_DELAY_NSEC;

    while (ts.tv_nsec >= 1000000000) { // nsが1sを超えた場合の処理
        ts.tv_nsec -= 1000000000;
        ts.tv_sec += 1;
    }
    return ts;
}

long usec_to_timeout(struct timespec ends_at)
{
    if (ends_at.tv_sec == -1 && ends_at.tv_nsec == -1) return 0;

    struct timespec starts_at = current_clocktime_ts();
    long sec_diff = ends_at.tv_sec - starts_at.tv_sec;
    long nsec_diff = ends_at.tv_nsec - starts_at.tv_nsec;
    long remaining = sec_diff * 1000000L + nsec_diff / 1000;

    return remaining > 0 ? remaining : 0;
}

int is_timeout(struct timespec expires_at) {
    struct timespec current = current_clocktime_ts();

    if (current.tv_sec > expires_at.tv_sec) return 1;
    if (current.tv_sec == expires_at.tv_sec && current.tv_nsec > expires_at.tv_nsec) return 1;
    return 0;
}

struct resolved_addrinfos
{
    struct addrinfo *ip6_ai;
    struct addrinfo *ip4_ai;
};

struct addrinfo *
select_addrinfo(struct resolved_addrinfos *addrinfos, int last_family)
{
    int priority_on_v6[2] = { AF_INET6, AF_INET };
    int priority_on_v4[2] = { AF_INET, AF_INET6 };
    int *precedences = last_family == AF_INET6 ? priority_on_v4 : priority_on_v6;
    struct addrinfo *selected_ai = NULL;

    for (int i = 0; i < 2; i++) {
        if (precedences[i] == AF_INET6) {
            selected_ai = addrinfos->ip6_ai;
            if (selected_ai) {
                addrinfos->ip6_ai = selected_ai->ai_next;
                break;
            }
        } else {
            selected_ai = addrinfos->ip4_ai;
            if (selected_ai) {
                addrinfos->ip4_ai = selected_ai->ai_next;
                break;
            }
        }
    }
    return selected_ai;
}

static int
initialize_read_fds(int initial_nfds, const int fd, fd_set *set)
{
    FD_ZERO(set);
    FD_SET(fd, set);
    return (fd + 1) > initial_nfds ? fd + 1 : initial_nfds;
}

static int
initialize_write_fds(const int *fds, int fds_size, fd_set *set)
{
    if (fds_size == 0) return 0;

    int nfds = 0;
    FD_ZERO(set);

    for (int i = 0; i < fds_size; i++) {
        int fd = fds[i];
        if (fd < 0) continue;
        if (fd > nfds) nfds = fd;
        FD_SET(fd, set);
    }

    if (nfds > 0) nfds++;
    return nfds;
}

static int
find_connected_socket(int *fds, int fds_size, fd_set *writefds)
{
    for (int i = 0; i < fds_size; i++) {
        int fd = fds[i];

        if (fd < 0 || !FD_ISSET(fd, writefds)) continue;

        int error;
        socklen_t len = sizeof(error);

        if (getsockopt(fd, SOL_SOCKET, SO_ERROR, &error, &len) == 0) {
            if (error == 0) { // success
                fds[i] = -1;
                return fd;
            } else { // fail
                errno = error;
                close_fd(fd);
                fds[i] = -1;
                break;
            }
        }
    }
    return -1;
}

static int
is_connecting_fds_empty(const int *fds, int fds_size)
{
    for (int i = 0; i < fds_size; i++) {
        if (fds[i] > 0) return false;
    }
    return true;
}

int is_specified_ip_address(const char *hostname)
{
    struct in_addr ipv4addr;
    struct in6_addr ipv6addr;

    return (inet_pton(AF_INET6, hostname, &ipv6addr) == 1 ||
            inet_pton(AF_INET, hostname, &ipv4addr) == 1);
}

struct inetsock_happy_arg
{
    struct inetsock_arg *inetsock_resource;
    const char *hostp, *portp;
    int *families;
    int families_size;
    int additional_flags;
    rb_nativethread_lock_t *lock;
    struct rb_getaddrinfo_happy_entry *getaddrinfo_entries[2];
    struct rb_getaddrinfo_happy_shared *getaddrinfo_shared;
    int connecting_fds_size, connecting_fds_capacity, connected_fd;
    int *connecting_fds;
};

static VALUE
init_inetsock_internal_happy(VALUE v)
{
    struct inetsock_happy_arg *arg = (void *)v;
    struct inetsock_arg *inetsock = arg->inetsock_resource;
    struct addrinfo *remote_ai = NULL, *local_ai = NULL;
    int fd, last_error = 0, status = 0, local_status = 0;
    const char *syscall = 0;

    // TODO ユーザー指定のタイムアウトに関する変数定義

    int remote_addrinfo_hints = 0;

    #ifdef HAVE_CONST_AI_ADDRCONFIG
    remote_addrinfo_hints |= AI_ADDRCONFIG;
    #endif

    struct rb_getaddrinfo_happy_shared *getaddrinfo_shared = arg->getaddrinfo_shared;
    int families_size = arg->families_size;

    int wait_resolution_pipe, notify_resolution_pipe;
    int pipefd[2];

    struct wait_happy_eyeballs_fds_arg wait_arg;

    pthread_t threads[families_size];
    char resolved_type[2];
    ssize_t resolved_type_size;

    pipe(pipefd);
    wait_resolution_pipe = pipefd[IPV6_ENTRY_POS];
    notify_resolution_pipe = pipefd[IPV4_ENTRY_POS];

    getaddrinfo_shared->node = strdup(arg->hostp);
    getaddrinfo_shared->service = strdup(arg->portp);
    getaddrinfo_shared->refcount = families_size + 1;
    getaddrinfo_shared->notify = notify_resolution_pipe;
    getaddrinfo_shared->wait = wait_resolution_pipe;
    rb_nativethread_lock_initialize(getaddrinfo_shared->lock);
    getaddrinfo_shared->connecting_fds = arg->connecting_fds;
    getaddrinfo_shared->connecting_fds_size = arg->connecting_fds_size;

    fd_set readfds, writefds;
    FD_ZERO(&readfds);
    FD_ZERO(&writefds);
    wait_arg.readfds = readfds;
    wait_arg.writefds = writefds;
    wait_arg.nfds = 0;
    wait_arg.delay = NULL;

    struct rb_getaddrinfo_happy_entry *tmp_getaddrinfo_entry = NULL;
    struct resolved_addrinfos selectable_addrinfos = { NULL, NULL };
    struct addrinfo *tmp_selected_ai;

    // HEv2対応前の変数定義 ----------------------------
    // struct inetsock_arg *arg = (void *)v;
    // int error = 0;
    int type = inetsock->type;
    struct addrinfo *res, *lres;
    // int fd, status = 0, local = 0;
    int family = AF_UNSPEC;
    // const char *syscall = 0;
    VALUE connect_timeout = inetsock->connect_timeout;
    struct timeval tv_storage;
    struct timeval *tv = NULL;

    if (!NIL_P(connect_timeout)) {
        tv_storage = rb_time_interval(connect_timeout);
        tv = &tv_storage;
    }
    // -------------------------------------------

    // debug
    int debug = true;
    int count = 0;

    // 接続開始 -----------------------------------
    /*
     * Maybe also accept a local address
     */
    // TODO local_host / local_portが指定された場合

    struct addrinfo getaddrinfo_hints[families_size];

    for (int i = 0; i < families_size; i++) { // 1周目...IPv6 / 2周目...IPv4
        allocate_rb_getaddrinfo_happy_hints(
            &getaddrinfo_hints[i],
            arg->families[i],
            remote_addrinfo_hints,
            arg->additional_flags
        );

        arg->getaddrinfo_entries[i]->hints = getaddrinfo_hints[i];
        arg->getaddrinfo_entries[i]->ai = NULL;
        arg->getaddrinfo_entries[i]->family = arg->families[i];
        arg->getaddrinfo_entries[i]->refcount = 2;

        if (do_pthread_create(&threads[i], do_rb_getaddrinfo_happy, arg->getaddrinfo_entries[i]) != 0) {
            last_error = EAI_AGAIN;
            rb_syserr_fail(EAI_AGAIN, NULL); // TODO 要確認
        }
        pthread_detach(threads[i]);
    }
    // -------------------------------------------

    while (true) {
        count++;
        if (debug) printf("[DEBUG] %d: ** Check for readying to connect **\n", count);
        // TODO if 接続開始条件を満たしている

        if (debug) printf("[DEBUG] %d: ** Start to connect **\n", count);
        // TODO 接続開始

        // TODO タイムアウト値の設定

        // ------------------- WIP ----------------------
        if (debug) printf("[DEBUG] %d: ** Start to wait **\n", count);
        // TODO 待機開始
        wait_arg.nfds = initialize_read_fds(0, wait_resolution_pipe, &wait_arg.readfds);
        rb_thread_call_without_gvl2(wait_happy_eyeballs_fds, &wait_arg, cancel_happy_eyeballs_fds, &getaddrinfo_shared);

        // TODO 割り込み時の処理

        status = wait_arg.status;
        syscall = "select(2)";
        if (status < 0) rb_syserr_fail(errno, "select(2)");

        resolved_type_size = read(wait_resolution_pipe, resolved_type, sizeof(resolved_type) - 1);
        if (resolved_type_size < 0) {
            last_error = errno;
            // TODO 例外を発生させる
        }

        resolved_type[resolved_type_size] = '\0';
        // TODO 解決できたアドレスファミリを確認し、適切に保存する

        // ------------------- WIP ----------------------

        if (debug) printf("[DEBUG] %d: ** Check for writable_sockets **\n", count);
        // TODO 接続状態の確認
        if (count == 2) { // TODO if 接続確立している
            puts("connection established");
            break;
        }

        if (debug) printf("[DEBUG] %d: ** Check for hostname resolution finish **\n", count);
        // TODO 解決したaddrinfoの保存

        if (debug) printf("[DEBUG] %d: ** Check for exiting **\n", count);
        // TODO if 次のループに進むことができる

        if (debug) puts("------------");
    }
    // TODO
    // return rsock_init_sock(inetsock->sock, fd);

    // HEv2対応前 ---------------------------------
    inetsock->remote.res = rsock_addrinfo(
        inetsock->remote.host,
        inetsock->remote.serv,
        family,
        SOCK_STREAM,
        0
    );

    /*
     * Maybe also accept a local address
     */

    if ((!NIL_P(inetsock->local.host) || !NIL_P(inetsock->local.serv))) {
        inetsock->local.res = rsock_addrinfo(
            inetsock->local.host,
            inetsock->local.serv,
            family,
            SOCK_STREAM,
            0
        );
    }

    inetsock->fd = fd = -1;
    for (res = inetsock->remote.res->ai; res; res = res->ai_next) {
        #if !defined(INET6) && defined(AF_INET6)
        if (res->ai_family == AF_INET6)
            continue;
        #endif
        lres = NULL;

        if (inetsock->local.res) {
            for (lres = inetsock->local.res->ai; lres; lres = lres->ai_next) {
                if (lres->ai_family == res->ai_family)
                    break;
            }

            if (!lres) {
                if (res->ai_next || status < 0)
                    continue;
                /* Use a different family local address if no choice, this
                 * will cause EAFNOSUPPORT. */
                lres = inetsock->local.res->ai;
            }
        }

        status = rsock_socket(res->ai_family,res->ai_socktype,res->ai_protocol);
        syscall = "socket(2)";
        fd = status;

        if (fd < 0) {
            last_error = errno;
            continue;
        }
        inetsock->fd = fd;

        if (lres) {
            #if !defined(_WIN32) && !defined(__CYGWIN__)
            status = 1;
            setsockopt(
                fd,
                SOL_SOCKET,
                SO_REUSEADDR,
                (char*)&status,
                (socklen_t)sizeof(status)
            );
            #endif
            status = bind(fd, lres->ai_addr, lres->ai_addrlen);
            local_status = status;
            syscall = "bind(2)";
        }

        if (status >= 0) {
            status = rsock_connect(
                fd,
                res->ai_addr,
                res->ai_addrlen,
                false,
                tv
            );
            syscall = "connect(2)";
        }

        if (status < 0) {
            last_error = errno;
            close(fd);
            inetsock->fd = fd = -1;
            continue;
        } else
            break;
    }

    if (status < 0) {
        VALUE host, port;

        if (local_status < 0) {
            host = inetsock->local.host;
            port = inetsock->local.serv;
        } else {
            host = inetsock->remote.host;
            port = inetsock->remote.serv;
        }

        rsock_syserr_fail_host_port(last_error, syscall, host, port);
    }

    inetsock->fd = -1;

    /* create new instance */
    return rsock_init_sock(inetsock->sock, fd);
    // ---------------------------------
}

VALUE
rsock_init_inetsock(VALUE sock, VALUE remote_host, VALUE remote_serv,
                    VALUE local_host, VALUE local_serv, int type,
                    VALUE resolv_timeout, VALUE connect_timeout, VALUE fast_fallback)
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

    if (type == INET_CLIENT && HAPPY_EYEBALLS_INIT_INETSOCK_IMPL && RTEST(fast_fallback)) {
        char *hostp, *portp;
        char hbuf[NI_MAXHOST], pbuf[NI_MAXSERV];
        int additional_flags = 0;
        hostp = host_str(arg.remote.host, hbuf, sizeof(hbuf), &additional_flags);
        portp = port_str(arg.remote.serv, pbuf, sizeof(pbuf), &additional_flags);

        if (!is_specified_ip_address(hostp)) {
            struct inetsock_happy_arg inetsock_happy_resource;
            memset(&inetsock_happy_resource, 0, sizeof(inetsock_happy_resource));

            inetsock_happy_resource.inetsock_resource = &arg;
            inetsock_happy_resource.hostp = hostp;
            inetsock_happy_resource.portp = portp;
            inetsock_happy_resource.additional_flags = additional_flags;
            inetsock_happy_resource.connected_fd = -1;

            int families[2] = { AF_INET6, AF_INET };
            inetsock_happy_resource.families = families;
            inetsock_happy_resource.families_size = sizeof(families) / sizeof(int);

            inetsock_happy_resource.getaddrinfo_shared = create_rb_getaddrinfo_happy_shared();
            if (!inetsock_happy_resource.getaddrinfo_shared) rb_syserr_fail(EAI_MEMORY, NULL);

            inetsock_happy_resource.getaddrinfo_shared->lock = malloc(sizeof(rb_nativethread_lock_t));
            if (!inetsock_happy_resource.getaddrinfo_shared->lock) rb_syserr_fail(EAI_MEMORY, NULL);

            for (int i = 0; i < inetsock_happy_resource.families_size; i++) {
                inetsock_happy_resource.getaddrinfo_entries[i] = allocate_rb_getaddrinfo_happy_entry();
                if (!(inetsock_happy_resource.getaddrinfo_entries[i])) rb_syserr_fail(EAI_MEMORY, NULL);
                inetsock_happy_resource.getaddrinfo_entries[i]->shared = inetsock_happy_resource.getaddrinfo_shared;
            }

            inetsock_happy_resource.getaddrinfo_shared->cancelled = false;

            return rb_ensure(init_inetsock_internal_happy, (VALUE)&inetsock_happy_resource,
                             inetsock_cleanup_happy, (VALUE)&inetsock_happy_resource);
        }
    }

    return rb_ensure(init_inetsock_internal, (VALUE)&arg,
                     inetsock_cleanup, (VALUE)&arg);
}
```

```c
// ext/socket/tcpserver.c

static VALUE
tcp_svr_init(int argc, VALUE *argv, VALUE sock)
{
    // ...
    return rsock_init_inetsock(sock, hostname, port, Qnil, Qnil, INET_SERVER, Qnil, Qnil, Qfalse); // 変更
}
```

```c
// ext/socket/sockssocket.c

static VALUE
socks_init(VALUE sock, VALUE host, VALUE port)
{
    // ...
    return rsock_init_inetsock(sock, host, port, Qnil, Qnil, INET_SOCKS, Qnil, Qnil, Qfalse);
}
```
