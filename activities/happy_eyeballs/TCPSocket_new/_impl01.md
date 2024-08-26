# 7/10 -
- (参照先: `getaddrinfo/_impl00`)
- 状態管理をやめ、ifによる条件分岐をベースに処理を実行する

```c
// ext/socket/ipsocket.c

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

static struct rb_getaddrinfo_happy_shared *
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

static void
allocate_rb_getaddrinfo_happy_hints(struct addrinfo *hints, int family, int remote_addrinfo_hints, int additional_flags)
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
    fd_set *readfds, *writefds;
    struct timeval *delay;
};

static void *
wait_happy_eyeballs_fds(void *ptr)
{
    struct wait_happy_eyeballs_fds_arg *arg = (struct wait_happy_eyeballs_fds_arg *)ptr;
    int status;
    status = select(arg->nfds, arg->readfds, arg->writefds, NULL, arg->delay);
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

struct timespec
current_clocktime_ts()
{
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return ts;
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

    FD_ZERO(set);
    int nfds = 0;

    for (int i = 0; i < fds_size; i++) {
        int fd = fds[i];
        if (fd < 0) continue;
        if (fd > nfds) nfds = fd;
        FD_SET(fd, set);
    }

    if (nfds > 0) nfds++;
    return nfds;
}

int
is_specified_ip_address(const char *hostname)
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
    int family_size;
    int additional_flags;
    rb_nativethread_lock_t *lock;
    struct rb_getaddrinfo_happy_entry *getaddrinfo_entries[2];
    struct rb_getaddrinfo_happy_shared *getaddrinfo_shared;
    int connecting_fds_size, connecting_fds_capacity;
    int *connecting_fds;
};

struct hostname_resolution_result
{
    struct addrinfo *ai;
    int finished;
    int succeed;
};

struct hostname_resolution_store
{
    struct hostname_resolution_result v6;
    struct hostname_resolution_result v4;
    int is_all_finised;
};

int
any_addrinfos(struct hostname_resolution_store *resolution_store)
{
    return resolution_store->v6.ai || resolution_store->v4.ai;
}

void
set_timeout_tv(struct timeval *tv, long ms, struct timespec from)
{
    long seconds = ms / 1000;
    long nanoseconds = (ms % 1000) * 1000000;

    from.tv_sec += seconds;
    from.tv_nsec += nanoseconds;

    while (from.tv_nsec >= 1000000000) { // nsが1sを超えた場合の処理
        from.tv_nsec -= 1000000000;
        from.tv_sec += 1;
    }

    tv->tv_sec = from.tv_sec;
    tv->tv_usec = (int)(from.tv_nsec / 1000);
}

struct timeval
add_ts_to_tv(struct timeval tv, struct timespec ts)
{
    long ts_usec = ts.tv_nsec / 1000;
    tv.tv_sec += ts.tv_sec;
    tv.tv_usec += ts_usec;

    if (tv.tv_usec >= 1000000) {
        tv.tv_sec += tv.tv_usec / 1000000;
        tv.tv_usec = tv.tv_usec % 1000000;
    }

    return tv;
}

int
is_infinity(struct timeval tv)
{
    // {-1, -1 } as infinity
    return tv.tv_sec == -1 || tv.tv_usec == -1;
}

int
is_timeout_tv(struct timeval *timeout_tv, struct timespec now) {
    if (!timeout_tv) return false;

    struct timespec tv;
    tv.tv_sec = timeout_tv->tv_sec;
    tv.tv_nsec = timeout_tv->tv_usec * 1000;

    if (tv.tv_sec > now.tv_sec) return true;
    if (tv.tv_sec < now.tv_sec) return false;
    if (tv.tv_nsec >= now.tv_nsec) return true;

    return false;
}

struct timeval *
select_expires_at(
    struct hostname_resolution_store *resolution_store,
    struct timeval *resolution_delay,
    struct timeval *connection_attempt_delay,
    struct timeval *user_specified_resolv_timeout_at,
    struct timeval *user_specified_connect_timeout_at
) {
    if (any_addrinfos(resolution_store)) {
        return resolution_delay ? resolution_delay : connection_attempt_delay;
    }

    struct timeval *timeout = NULL;

    if (user_specified_resolv_timeout_at) {
        if (is_infinity(*user_specified_resolv_timeout_at)) return user_specified_resolv_timeout_at;
        timeout = user_specified_resolv_timeout_at;
    }

    if (user_specified_connect_timeout_at) {
        if (is_infinity(*user_specified_connect_timeout_at)) return user_specified_connect_timeout_at;
        if (!timeout || timercmp(user_specified_connect_timeout_at, timeout, >)) {
            return user_specified_connect_timeout_at;
        }
    }

    return timeout;
}

struct timeval
tv_to_timeout(struct timeval *ends_at, struct timespec now)
{
    struct timeval delay;
    struct timespec expires_at;
    expires_at.tv_sec = ends_at->tv_sec;
    expires_at.tv_nsec = ends_at->tv_usec * 1000;

    struct timespec diff;
    diff.tv_sec = expires_at.tv_sec - now.tv_sec;

    if (expires_at.tv_nsec >= now.tv_nsec) {
        diff.tv_nsec = expires_at.tv_nsec - now.tv_nsec;
    } else {
        diff.tv_sec -= 1;
        diff.tv_nsec = (1000000000 + expires_at.tv_nsec) - now.tv_nsec;
    }

    delay.tv_sec = diff.tv_sec;
    delay.tv_usec = (int)diff.tv_nsec / 1000;

    return delay;
}

struct addrinfo *
pick_addrinfo(struct hostname_resolution_store *resolution_store, int last_family)
{
    int priority_on_v6[2] = { AF_INET6, AF_INET };
    int priority_on_v4[2] = { AF_INET, AF_INET6 };
    int *precedences = last_family == AF_INET6 ? priority_on_v4 : priority_on_v6;
    struct addrinfo *selected_ai = NULL;

    for (int i = 0; i < 2; i++) {
        if (precedences[i] == AF_INET6) {
            selected_ai = resolution_store->v6.ai;
            if (selected_ai) {
                resolution_store->v6.ai = selected_ai->ai_next;
                break;
            }
        } else {
            selected_ai = resolution_store->v4.ai;
            if (selected_ai) {
                resolution_store->v4.ai = selected_ai->ai_next;
                break;
            }
        }
    }
    return selected_ai;
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
                close(fd);
                fds[i] = -1;
                break;
            }
        }
    }
    return -1;
}

static int
connecting_fds_empty(const int *fds, int fds_size)
{
    for (int i = 0; i < fds_size; i++) {
        if (fds[i] > 0) return false;
    }
    return true;
}

static VALUE
init_inetsock_internal_happy(VALUE v)
{
    struct inetsock_happy_arg *arg = (void *)v;
    struct inetsock_arg *inetsock = arg->inetsock_resource;
    VALUE resolv_timeout = inetsock->resolv_timeout;
    VALUE connect_timeout = inetsock->connect_timeout;
    struct addrinfo *remote_ai = NULL, *local_ai = NULL;
    int fd, status = 0, local_status = 0;
    int remote_addrinfo_hints = 0;
    int last_error = 0;
    const char *syscall = 0;

    #ifdef HAVE_CONST_AI_ADDRCONFIG
    remote_addrinfo_hints |= AI_ADDRCONFIG;
    #endif

    int family_size = arg->family_size;

    struct rb_getaddrinfo_happy_shared *getaddrinfo_shared = NULL;
    char resolved_type[2];
    ssize_t resolved_type_size;
    int hostname_resolution_waiter;

    fd_set *writefds;
    fd_set wfds;
    writefds = &wfds;

    struct wait_happy_eyeballs_fds_arg wait_arg;
    struct timeval *ends_at = NULL;
    struct timeval delay = (struct timeval){ -1, -1 };
    wait_arg.nfds = 0;
    wait_arg.writefds = writefds;
    wait_arg.status = 0;

    struct hostname_resolution_store resolution_store;
    resolution_store.is_all_finised = false;
    resolution_store.v6.ai = NULL;
    resolution_store.v6.finished = false;
    resolution_store.v4.ai = NULL;
    resolution_store.v4.finished = false;

    int last_family = 0;

    int connecting_fds_size = arg->connecting_fds_size;
    int initial_capacity = 10;
    int current_capacity = initial_capacity;
    arg->connecting_fds = (int *)malloc(initial_capacity * sizeof(int));
    if (!arg->connecting_fds) rb_syserr_fail(EAI_MEMORY, NULL);
    arg->connecting_fds_capacity = initial_capacity;

    // nil = null
    // Float::INFINITY = { -1, -1 }
    struct timeval resolution_delay_storage;
    struct timeval *resolution_delay_expires_at = NULL;
    struct timeval connection_attempt_delay_strage;
    struct timeval *connection_attempt_delay_expires_at = NULL;
    struct timeval user_specified_resolv_timeout_storage;
    struct timeval *user_specified_resolv_timeout_at = NULL;
    struct timeval user_specified_connect_timeout_storage;
    struct timeval *user_specified_connect_timeout_at = NULL;
    struct timespec now = current_clocktime_ts();

    if (family_size == 1) {
        int family = arg->families[0];
        inetsock->remote.res = rsock_addrinfo(
            inetsock->remote.host,
            inetsock->remote.serv,
            family,
            SOCK_STREAM,
            0
        );

        if (family == AF_INET6) {
            resolution_store.v6.ai = inetsock->remote.res->ai;
            resolution_store.v6.finished = true;
            resolution_store.v4.finished = true;
        } else if (family == AF_INET) {
            resolution_store.v4.ai = inetsock->remote.res->ai;
            resolution_store.v4.finished = true;
            resolution_store.v6.finished = true;
        }
        resolution_store.is_all_finised = true;
        wait_arg.readfds = NULL;
    } else {
        arg->getaddrinfo_shared = create_rb_getaddrinfo_happy_shared();
        if (!arg->getaddrinfo_shared) rb_syserr_fail(EAI_MEMORY, NULL);

        arg->getaddrinfo_shared->lock = malloc(sizeof(rb_nativethread_lock_t));
        if (!arg->getaddrinfo_shared->lock) rb_syserr_fail(EAI_MEMORY, NULL);
        rb_nativethread_lock_initialize(arg->getaddrinfo_shared->lock);

        for (int i = 0; i < arg->family_size; i++) {
            arg->getaddrinfo_entries[i] = allocate_rb_getaddrinfo_happy_entry();
            if (!(arg->getaddrinfo_entries[i])) rb_syserr_fail(EAI_MEMORY, NULL);
            arg->getaddrinfo_entries[i]->shared = arg->getaddrinfo_shared;
        }

        arg->getaddrinfo_shared->cancelled = false;
        getaddrinfo_shared = arg->getaddrinfo_shared;

        pthread_t threads[family_size];
        int hostname_resolution_notifier;
        int pipefd[2];
        pipe(pipefd);
        hostname_resolution_waiter = pipefd[0];
        hostname_resolution_notifier = pipefd[1];

        fd_set *readfds;
        fd_set rfds;
        readfds = &rfds;
        wait_arg.readfds = readfds;

        getaddrinfo_shared->node = strdup(arg->hostp);
        getaddrinfo_shared->service = strdup(arg->portp);
        getaddrinfo_shared->refcount = family_size + 1;
        getaddrinfo_shared->notify = hostname_resolution_notifier;
        getaddrinfo_shared->wait = hostname_resolution_waiter;
        getaddrinfo_shared->connecting_fds = arg->connecting_fds;
        getaddrinfo_shared->connecting_fds_size = arg->connecting_fds_size;

        /*
         * Maybe also accept a local address
         */

        struct addrinfo getaddrinfo_hints[family_size];

        for (int i = 0; i < family_size; i++) { // 1周目...IPv6 / 2周目...IPv4
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
                rsock_raise_resolution_error("getaddrinfo", last_error);
            }
            pthread_detach(threads[i]);
        }

        if (NIL_P(resolv_timeout)) {
            user_specified_resolv_timeout_storage = (struct timeval){ -1, -1 };
        } else {
            struct timeval resolv_timeout_tv = rb_time_interval(resolv_timeout);
            user_specified_resolv_timeout_storage = add_ts_to_tv(resolv_timeout_tv, now);
        }
        user_specified_resolv_timeout_at = &user_specified_resolv_timeout_storage;
    }

    // debug
    int debug = true;
    int count = 0;

    while (true) {
        count++;
        if (debug) printf("[DEBUG] %d: ** Check for readying to connect **\n", count);
        if (any_addrinfos(&resolution_store) &&
            !resolution_delay_expires_at &&
            !connection_attempt_delay_expires_at) {
            if (debug) printf("[DEBUG] %d: ** Select addrinfo **\n", count);
            while ((remote_ai = pick_addrinfo(&resolution_store, last_family))) {
                fd = -1;
                if (debug) printf("[DEBUG] %d: remote_ai %p\n", count, remote_ai);

                #if !defined(INET6) && defined(AF_INET6)
                if (remote_ai->ai_family == AF_INET6) {
                    if (any_addrinfos(&resolution_store)) {
                        continue;
                    } else if (connecting_fds_empty(arg->connecting_fds, connecting_fds_size) || resolution_store.is_all_finised) {
                        break;
                    } else {
                        if (local_status < 0)
                        {
                            // local_host / local_portが指定されており、ローカルに接続可能なアドレスファミリがなかった場合
                            rsock_syserr_fail_host_port(last_error, syscall, inetsock->local.host, inetsock->local.serv);
                        }
                        rsock_syserr_fail_host_port(last_error, syscall, inetsock->remote.host, inetsock->remote.serv);
                    }
                }
                #endif

                local_ai = NULL;

                if (inetsock->local.res) {
                    for (local_ai = inetsock->local.res->ai; local_ai; local_ai = local_ai->ai_next) {
                        if (local_ai->ai_family == remote_ai->ai_family) break;
                    }
                    if (!local_ai) {
                        if (any_addrinfos(&resolution_store)) {
                            // Try other addrinfo in next loop
                            continue;
                        } else {
                            if (connecting_fds_empty(arg->connecting_fds, connecting_fds_size) &&
                                resolution_store.is_all_finised) {
                                /* Use a different family local address if no choice, this
                                 * will cause EAFNOSUPPORT. */
                                last_error = EAFNOSUPPORT;
                                rsock_syserr_fail_host_port(last_error, syscall, inetsock->local.host, inetsock->local.serv);
                            }
                        }
                    }
                }

                if (debug) printf("[DEBUG] %d: ** Create socket **\n", count);
                status = rsock_socket(remote_ai->ai_family, remote_ai->ai_socktype, remote_ai->ai_protocol);
                syscall = "socket(2)";
                fd = status;
                if (debug) printf("[DEBUG] %d: fd %d\n", count, fd);

                if (fd < 0) { // socket(2)に失敗
                    last_error = errno;
                    fd = -1;
                    if (any_addrinfos(&resolution_store) ||
                        connecting_fds_empty(arg->connecting_fds, connecting_fds_size) ||
                        !resolution_store.is_all_finised) {
                        break;
                    } else {
                        if (local_status < 0) {
                            // local_host / local_portが指定されており、ローカルに接続可能なアドレスファミリがなかった場合
                            rsock_syserr_fail_host_port(last_error, syscall, inetsock->local.host, inetsock->local.serv);
                        }
                        rsock_syserr_fail_host_port(last_error, syscall, inetsock->remote.host, inetsock->remote.serv);
                    }
                }

                if (debug) printf("[DEBUG] %d: ** Start to connect to %d **\n", count, remote_ai->ai_family);
                if (any_addrinfos(&resolution_store) ||
                    !connecting_fds_empty(arg->connecting_fds, connecting_fds_size) ||
                    !resolution_store.is_all_finised) {

                    if (local_ai) {
                        // TODO?
                        // #if !defined(_WIN32) && !defined(__CYGWIN__)
                        // #endif
                        status = bind(fd, local_ai->ai_addr, local_ai->ai_addrlen);
                        local_status = status;
                        syscall = "bind(2)";

                        if (status < 0) { // bind(2) に失敗
                            last_error = errno;
                            fd = -1;

                            if (any_addrinfos(&resolution_store)) {
                                // Try other addrinfo in next loop
                                continue;
                            } else {
                                break;
                            }
                        }
                    }

                    socket_nonblock_set(fd);
                    status = connect(fd, remote_ai->ai_addr, remote_ai->ai_addrlen);
                    syscall = "connect(2)";
                    last_family = remote_ai->ai_family;
                } else {
                    if (!NIL_P(connect_timeout)) {
                        user_specified_connect_timeout_storage = rb_time_interval(connect_timeout);
                        user_specified_connect_timeout_at = &user_specified_connect_timeout_storage;
                    }

                    if (local_ai) {
                        // TODO?
                        // #if !defined(_WIN32) && !defined(__CYGWIN__)
                        // #endif
                        status = bind(fd, local_ai->ai_addr, local_ai->ai_addrlen);
                        local_status = status;
                        syscall = "bind(2)";

                        if (status < 0) { // bind(2) に失敗
                            last_error = errno;
                            fd = -1;
                            break;
                        }
                    }

                    status = rsock_connect(
                        fd,
                        remote_ai->ai_addr,
                        remote_ai->ai_addrlen,
                        0,
                        user_specified_connect_timeout_at
                    );
                    syscall = "connect(2)";
                }

                if (status == 0) { // 接続に成功
                    if (debug) printf("[DEBUG] %d: ** fd %d is connected successfully **\n", count, fd);
                    /* create new instance */
                    return rsock_init_sock(inetsock->sock, fd);
                } else if (errno == EINPROGRESS) { // 接続中
                    if (debug) printf("[DEBUG] %d: connection inprogress\n", count);
                    if (current_capacity == connecting_fds_size) {
                        int new_capacity = current_capacity + initial_capacity;
                        arg->connecting_fds = (int*)realloc(arg->connecting_fds, new_capacity * sizeof(int));
                        if (!arg->connecting_fds) rb_syserr_fail(EAI_MEMORY, NULL);
                        current_capacity = new_capacity;
                        arg->connecting_fds_capacity = current_capacity;
                    }
                    arg->connecting_fds[connecting_fds_size] = fd;
                    (connecting_fds_size)++;
                    wait_arg.writefds = writefds;

                    set_timeout_tv(&connection_attempt_delay_strage, 250, now);
                    connection_attempt_delay_expires_at = &connection_attempt_delay_strage;

                    if (!any_addrinfos(&resolution_store)) {
                        if (NIL_P(connect_timeout)) {
                            user_specified_connect_timeout_storage = (struct timeval){ -1, -1 };
                        } else {
                            struct timeval connect_timeout_tv = rb_time_interval(connect_timeout);
                            user_specified_connect_timeout_storage = add_ts_to_tv(connect_timeout_tv, now);
                        }
                        user_specified_connect_timeout_at = &user_specified_connect_timeout_storage;
                    }

                    if (debug) {
                        for (int i = 0; i < connecting_fds_size; i++) {
                            printf("[DEBUG] %d: connecting fd %d\n", count, arg->connecting_fds[i]);
                        }
                    }
                } else {
                    if (debug) printf("[DEBUG] %d: connection failed\n", count);
                    last_error = errno;
                    close(fd);

                    if (any_addrinfos(&resolution_store)) continue;

                    if (connecting_fds_empty(arg->connecting_fds, connecting_fds_size) &&
                        resolution_store.is_all_finised) break;

                    if (local_status < 0) {
                        // local_host / local_portが指定されており、ローカルに接続可能なアドレスファミリがなかった場合
                        rsock_syserr_fail_host_port(last_error, syscall, inetsock->local.host, inetsock->local.serv);
                    }
                    rsock_syserr_fail_host_port(last_error, syscall, inetsock->remote.host, inetsock->remote.serv);
                }
            }
        }

        ends_at = select_expires_at(
            &resolution_store,
            resolution_delay_expires_at,
            connection_attempt_delay_expires_at,
            user_specified_resolv_timeout_at,
            user_specified_connect_timeout_at
        );
        if (ends_at && !is_infinity(*ends_at)) {
            if (debug) printf("[DEBUG] %d: ends_at->tv_sec %ld\n", count, ends_at->tv_sec);
            if (debug) printf("[DEBUG] %d: ends_at->tv_usec %d\n", count, ends_at->tv_usec);
            delay = tv_to_timeout(ends_at, now);
            wait_arg.delay = &delay;
        } else {
            wait_arg.delay = NULL;
        }

        if (debug) printf("[DEBUG] %d: ** Start to wait **\n", count);

        // TODO fdsをまとめて初期化できるようにしたい
        wait_arg.nfds = initialize_write_fds(arg->connecting_fds, connecting_fds_size, wait_arg.writefds);
        if (!resolution_store.is_all_finised) {
            wait_arg.nfds = initialize_read_fds(wait_arg.nfds, hostname_resolution_waiter, wait_arg.readfds);
        }
        rb_thread_call_without_gvl2(wait_happy_eyeballs_fds, &wait_arg, cancel_happy_eyeballs_fds, &getaddrinfo_shared);

        // TODO 割り込み時の処理
        status = wait_arg.status;
        syscall = "select(2)";

        now = current_clocktime_ts();
        if (is_timeout_tv(resolution_delay_expires_at, now)) {
            resolution_delay_expires_at = NULL;
        }
        if (is_timeout_tv(connection_attempt_delay_expires_at, now)) {
            connection_attempt_delay_expires_at = NULL;
        }

        if (status < 0) rb_syserr_fail(errno, "select(2)");

        if (status > 0) {
            if (!resolution_store.is_all_finised && FD_ISSET(hostname_resolution_waiter, wait_arg.readfds)) { // 名前解決できた
                if (debug) printf("[DEBUG] %d: ** Hostname resolution finished **\n", count);
                // TODO この方法で良いのか要検討
                resolved_type_size = read(hostname_resolution_waiter, resolved_type, sizeof(resolved_type) - 1);
                if (resolved_type_size < 0) {
                    last_error = errno;
                    if (!any_addrinfos(&resolution_store) &&
                        connecting_fds_empty(arg->connecting_fds, connecting_fds_size) &&
                        resolution_store.is_all_finised) {
                        if (local_status < 0) {
                            // local_host / local_portが指定されており、ローカルに接続可能なアドレスファミリがなかった場合
                            rsock_syserr_fail_host_port(last_error, syscall, inetsock->local.host, inetsock->local.serv);
                        }
                        rsock_syserr_fail_host_port(last_error, syscall, inetsock->remote.host, inetsock->remote.serv);
                    }
                } else {
                    resolved_type[resolved_type_size] = '\0';

                    if (strcmp(resolved_type, IPV6_HOSTNAME_RESOLVED) == 0) { // IPv6解決
                        resolution_store.v6.ai = arg->getaddrinfo_entries[IPV6_ENTRY_POS]->ai;
                        resolution_store.v6.finished = true;
                        if (arg->getaddrinfo_entries[IPV6_ENTRY_POS]->err) {
                            last_error = arg->getaddrinfo_entries[IPV6_ENTRY_POS]->err;
                            resolution_store.v6.succeed = false;
                        } else {
                            resolution_store.v6.succeed = true;
                        }
                        if (resolution_store.v4.finished) resolution_store.is_all_finised = true;
                    } else if (strcmp(resolved_type, IPV4_HOSTNAME_RESOLVED) == 0) { // IPv4解決
                        resolution_store.v4.ai = arg->getaddrinfo_entries[IPV4_ENTRY_POS]->ai;
                        resolution_store.v4.finished = true;
                        if (arg->getaddrinfo_entries[IPV4_ENTRY_POS]->err) {
                            last_error = arg->getaddrinfo_entries[IPV4_ENTRY_POS]->err;
                            resolution_store.v4.succeed = false;
                        } else {
                            resolution_store.v4.succeed = true;
                        }
                    }

                    if (resolution_store.v4.finished) {
                        if (resolution_store.v6.finished) {
                            if (debug) printf("[DEBUG] %d: All hostname resolution is finished\n", count);
                            wait_arg.readfds = NULL;
                            resolution_delay_expires_at = NULL;
                            user_specified_resolv_timeout_at = NULL;
                            resolution_store.is_all_finised = true;
                        } else if (resolution_store.v4.succeed) {
                            if (debug) printf("[DEBUG] %d: Resolution Delay is ready\n", count);
                            set_timeout_tv(&resolution_delay_storage, 50, now);
                            resolution_delay_expires_at = &resolution_delay_storage;
                        }
                    }
                }
            } else {
                if (debug) printf("[DEBUG] %d: ** sockets become writable **\n", count);
                fd = find_connected_socket(arg->connecting_fds, connecting_fds_size, wait_arg.writefds);
                if (fd >= 0) {
                    if (debug) printf("[DEBUG] %d: ** fd %d is connected successfully **\n", count, fd);
                    /* create new instance */
                    return rsock_init_sock(inetsock->sock, fd);
                } else {
                    last_error = errno;
                    close(fd);
                    fd = -1;

                    if (any_addrinfos(&resolution_store) ||
                        !connecting_fds_empty(arg->connecting_fds, connecting_fds_size) ||
                        !resolution_store.is_all_finised) {
                        if (connecting_fds_empty(arg->connecting_fds, connecting_fds_size)) {
                            wait_arg.writefds = NULL;
                        } else {
                            user_specified_connect_timeout_at = NULL;
                        }
                    } else {
                        if (local_status < 0) {
                            // local_host / local_portが指定されており、ローカルに接続可能なアドレスファミリがなかった場合
                            rsock_syserr_fail_host_port(last_error, syscall, inetsock->local.host, inetsock->local.serv);
                        }
                        rsock_syserr_fail_host_port(last_error, syscall, inetsock->remote.host, inetsock->remote.serv);
                    }
                }
                break;
            }
            status = wait_arg.status = 0;
        }

        if (debug) printf("[DEBUG] %d: ** Check for exiting **\n", count);
        if (!any_addrinfos(&resolution_store)) {
            if (connecting_fds_empty(arg->connecting_fds, connecting_fds_size) && resolution_store.is_all_finised) {
                if (local_status < 0) {
                    // local_host / local_portが指定されており、ローカルに接続可能なアドレスファミリがなかった場合
                    rsock_syserr_fail_host_port(last_error, syscall, inetsock->local.host, inetsock->local.serv);
                }
                rsock_syserr_fail_host_port(last_error, syscall, inetsock->remote.host, inetsock->remote.serv);
            }

            if ((is_timeout_tv(user_specified_resolv_timeout_at, now) || resolution_store.is_all_finised) &&
                (is_timeout_tv(user_specified_connect_timeout_at, now) || connecting_fds_empty(arg->connecting_fds, connecting_fds_size))) {
                VALUE errno_module = rb_const_get(rb_cObject, rb_intern("Errno"));
                VALUE etimedout_error = rb_const_get(errno_module, rb_intern("ETIMEDOUT"));
                rb_raise(etimedout_error, "user specified timeout");
            }
        }

        if (debug) puts("------------");
        // TODO
        // ループを脱出してここでreturnするようにしないと警告が出る...
        // non-void function does not return a value in all control paths
    }
}

static VALUE
inetsock_cleanup_happy(VALUE v)
{
    struct inetsock_happy_arg *arg = (void *)v;
    struct inetsock_arg *inetsock_resource = arg->inetsock_resource;
    struct rb_getaddrinfo_happy_shared *getaddrinfo_shared = arg->getaddrinfo_shared;

    if (inetsock_resource->remote.res) {
        rb_freeaddrinfo(inetsock_resource->remote.res);
        inetsock_resource->remote.res = 0;
    }
    if (inetsock_resource->local.res) {
        rb_freeaddrinfo(inetsock_resource->local.res);
        inetsock_resource->local.res = 0;
    }
    if (inetsock_resource->fd >= 0) {
        close(inetsock_resource->fd);
    }

    if (getaddrinfo_shared) {
        int shared_need_free = 0;
        int need_free[2] = { 0, 0 };

        rb_nativethread_lock_lock(getaddrinfo_shared->lock);
        {
            for (int i = 0; i < arg->family_size; i++) {
                if (arg->getaddrinfo_entries[i] && --(arg->getaddrinfo_entries[i]->refcount) == 0) {
                    need_free[i] = 1;
                }
            }
            if (--(getaddrinfo_shared->refcount) == 0) {
                shared_need_free = 1;
            }
        }
        rb_nativethread_lock_unlock(getaddrinfo_shared->lock);

        for (int i = 0; i < arg->family_size; i++) {
            if (need_free[i]) free_rb_getaddrinfo_happy_entry(&arg->getaddrinfo_entries[i]);
        }
        if (shared_need_free) free_rb_getaddrinfo_happy_shared(&getaddrinfo_shared);
    }

    for (int i = 0; i < arg->connecting_fds_size; i++) {
        int connecting_fd = arg->connecting_fds[i];
        close_fd(connecting_fd);
    }

    free(arg->connecting_fds);
    arg->connecting_fds = NULL;

    return Qnil;
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
            int target_families[2] = { 0, 0 };
            int resolving_family_size = 0;

            /*
             * Maybe also accept a local address
             */
            if (!NIL_P(arg.local.host) || !NIL_P(arg.local.serv)) {
                arg.local.res = rsock_addrinfo(
                    arg.local.host,
                    arg.local.serv,
                    AF_UNSPEC,
                    SOCK_STREAM,
                    0
                );

                struct addrinfo *tmp_p = arg.local.res->ai;
                for (tmp_p; tmp_p != NULL; tmp_p = tmp_p->ai_next) {
                    if (target_families[0] == 0 && tmp_p->ai_family == AF_INET6) {
                        target_families[0] = AF_INET6;
                        resolving_family_size++;
                    }
                    if (target_families[1] == 0 && tmp_p->ai_family == AF_INET) {
                        target_families[1] = AF_INET;
                        resolving_family_size++;
                    }
                }
            }  else {
                resolving_family_size = 2;
                target_families[0] = AF_INET6;
                target_families[1] = AF_INET;
            }

            struct inetsock_happy_arg inetsock_happy_resource;
            memset(&inetsock_happy_resource, 0, sizeof(inetsock_happy_resource));

            inetsock_happy_resource.inetsock_resource = &arg;
            inetsock_happy_resource.hostp = hostp;
            inetsock_happy_resource.portp = portp;
            inetsock_happy_resource.additional_flags = additional_flags;

            int resolving_families[resolving_family_size];
            int resolving_family_index = 0;
            for (int i = 0; 2 > i; i++) {
                if (target_families[i] != 0) {
                    resolving_families[resolving_family_index] = target_families[i];
                    resolving_family_index++;
                }
            }
            inetsock_happy_resource.families = resolving_families;
            inetsock_happy_resource.family_size = resolving_family_size;

            printf("[DEBUG] resolving_family_size %d\n", resolving_family_size);

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
