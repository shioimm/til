# 7/10 -
- (参照先: `getaddrinfo/_impl01`)
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
    int cancelled;
    rb_nativethread_lock_t *lock;
    struct rb_getaddrinfo_happy_entry *getaddrinfo_entries[2];
    struct rb_getaddrinfo_happy_shared *getaddrinfo_shared;
    int connection_attempt_fds_size, connection_attempt_fds_capacity;
    int *connection_attempt_fds;
    VALUE test_mode_settings;
};

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
    int *cancelled;
};

static void *
wait_happy_eyeballs_fds(void *ptr)
{
    struct wait_happy_eyeballs_fds_arg *arg = (struct wait_happy_eyeballs_fds_arg *)ptr;
    int status;
    status = select(arg->nfds, arg->readfds, arg->writefds, NULL, arg->delay);
    arg->status = status;
    if (errno == EINTR) *arg->cancelled = true;
    return 0;
}

static void
cancel_happy_eyeballs_fds(void *ptr)
{
    if (!ptr) return;

    struct rb_getaddrinfo_happy_shared *arg = (struct rb_getaddrinfo_happy_shared *)ptr;

    rb_nativethread_lock_lock(arg->lock);
    {
        *arg->cancelled = true;
        write(arg->notify, SELECT_CANCELLED, strlen(SELECT_CANCELLED));
    }
    rb_nativethread_lock_unlock(arg->lock);
}

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

struct timespec
current_clocktime_ts()
{
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return ts;
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
    if (timeout_tv->tv_sec == -1 && timeout_tv->tv_usec == -1) return false;

    struct timespec tv;
    tv.tv_sec = timeout_tv->tv_sec;
    tv.tv_nsec = timeout_tv->tv_usec * 1000;

    if (tv.tv_sec < now.tv_sec) return true;
    if (tv.tv_sec == now.tv_sec && tv.tv_nsec < now.tv_nsec) return true;

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
        if (is_infinity(*user_specified_resolv_timeout_at)) return NULL;
        timeout = user_specified_resolv_timeout_at;
    }

    if (user_specified_connect_timeout_at) {
        if (is_infinity(*user_specified_connect_timeout_at)) return NULL;
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
no_in_progress_fds(const int *fds, int fds_size)
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
    VALUE test_mode_settings = arg->test_mode_settings;
    struct addrinfo *remote_ai = NULL, *local_ai = NULL;
    int fd = -1, connected_fd = -1, status = 0, local_status = 0;
    int remote_addrinfo_hints = 0;
    int last_error = 0;
    const char *syscall = 0;

    #ifdef HAVE_CONST_AI_ADDRCONFIG
    remote_addrinfo_hints |= AI_ADDRCONFIG;
    #endif

    int family_size = arg->family_size;

    struct rb_getaddrinfo_happy_shared *getaddrinfo_shared = NULL;
    pthread_t threads[family_size];
    char resolved_type[2];
    ssize_t resolved_type_size;
    int hostname_resolution_waiter, hostname_resolution_notifier;
    int pipefd[2];
    fd_set readfds, writefds;

    struct wait_happy_eyeballs_fds_arg wait_arg;
    struct timeval *ends_at = NULL;
    struct timeval delay = (struct timeval){ -1, -1 };
    wait_arg.nfds = 0;
    wait_arg.writefds = NULL;
    wait_arg.status = 0;

    struct hostname_resolution_store resolution_store;
    resolution_store.is_all_finised = false;
    resolution_store.v6.ai = NULL;
    resolution_store.v6.finished = false;
    resolution_store.v4.ai = NULL;
    resolution_store.v4.finished = false;

    int last_family = 0;

    int connection_attempt_fds_size = arg->connection_attempt_fds_size;
    int initial_capacity = 10;
    int current_capacity = initial_capacity;
    arg->connection_attempt_fds = (int *)malloc(initial_capacity * sizeof(int));
    if (!arg->connection_attempt_fds) rb_syserr_fail(EAI_MEMORY, NULL);
    arg->connection_attempt_fds_capacity = initial_capacity;

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
        pipe(pipefd);
        hostname_resolution_waiter = pipefd[0];
        int waiter_flags = fcntl(hostname_resolution_waiter, F_GETFL, 0);
        fcntl(hostname_resolution_waiter, F_SETFL, waiter_flags | O_NONBLOCK);
        hostname_resolution_notifier = pipefd[1];
        wait_arg.readfds = &readfds;

        arg->getaddrinfo_shared = create_rb_getaddrinfo_happy_shared();
        if (!arg->getaddrinfo_shared) rb_syserr_fail(EAI_MEMORY, NULL);

        arg->getaddrinfo_shared->lock = malloc(sizeof(rb_nativethread_lock_t));
        if (!arg->getaddrinfo_shared->lock) rb_syserr_fail(EAI_MEMORY, NULL);
        rb_nativethread_lock_initialize(arg->getaddrinfo_shared->lock);

        getaddrinfo_shared = arg->getaddrinfo_shared;
        getaddrinfo_shared->node = strdup(arg->hostp);
        getaddrinfo_shared->service = strdup(arg->portp);
        getaddrinfo_shared->refcount = family_size + 1;
        getaddrinfo_shared->notify = hostname_resolution_notifier;
        getaddrinfo_shared->wait = hostname_resolution_waiter;
        getaddrinfo_shared->connection_attempt_fds = arg->connection_attempt_fds;
        getaddrinfo_shared->connection_attempt_fds_size = arg->connection_attempt_fds_size;
        getaddrinfo_shared->cancelled = &arg->cancelled;
        wait_arg.cancelled = &arg->cancelled;

        for (int i = 0; i < arg->family_size; i++) {
            arg->getaddrinfo_entries[i] = allocate_rb_getaddrinfo_happy_entry();
            if (!(arg->getaddrinfo_entries[i])) rb_syserr_fail(EAI_MEMORY, NULL);
            arg->getaddrinfo_entries[i]->shared = arg->getaddrinfo_shared;
        }

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

            /* For testing HEv2 */
            if (!NIL_P(test_mode_settings) && RB_TYPE_P(test_mode_settings, T_HASH)) {
                VALUE test_delay_setting = rb_hash_aref(test_mode_settings, ID2SYM(rb_intern("delay")));
                if (!NIL_P(test_delay_setting)) {
                    const char *family_sym = arg->families[i] == AF_INET6 ? "ipv6" : "ipv4";
                    VALUE _test_delay_ms = rb_hash_aref(test_delay_setting, ID2SYM(rb_intern(family_sym)));
                    long test_delay_ms = NIL_P(_test_delay_ms) ? 0 : _test_delay_ms;
                    arg->getaddrinfo_entries[i]->sleep_ms = test_delay_ms;
                }
            }

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
        if (debug) printf("[DEBUG] %d: any_addrinfos %d\n", count, any_addrinfos(&resolution_store));
        if (debug) printf("[DEBUG] %d: resolution_delay_expires_at %p\n", count, resolution_delay_expires_at);
        if (debug) printf("[DEBUG] %d: connection_attempt_delay_expires_at %p\n", count, connection_attempt_delay_expires_at);
        if (any_addrinfos(&resolution_store) &&
            !resolution_delay_expires_at &&
            !connection_attempt_delay_expires_at) {
            if (debug) printf("[DEBUG] %d: ** Select addrinfo **\n", count);
            while ((remote_ai = pick_addrinfo(&resolution_store, last_family))) {
                fd = -1;
                if (debug) printf("[DEBUG] %d: remote_ai %p\n", count, remote_ai);

                #if !defined(INET6) && defined(AF_INET6)
                if (remote_ai->ai_family == AF_INET6) {
                    if (any_addrinfos(&resolution_store)) continue;

                    if (no_in_progress_fds(arg->connection_attempt_fds, connection_attempt_fds_size) ||
                        resolution_store.is_all_finised) break;

                    if (local_status < 0) {
                        rsock_syserr_fail_host_port(last_error, syscall, inetsock->local.host, inetsock->local.serv);
                    }
                    rsock_syserr_fail_host_port(last_error, syscall, inetsock->remote.host, inetsock->remote.serv);
                }
                #endif

                local_ai = NULL;

                if (inetsock->local.res) {
                    for (local_ai = inetsock->local.res->ai; local_ai; local_ai = local_ai->ai_next) {
                        if (local_ai->ai_family == remote_ai->ai_family) break;
                    }
                    if (!local_ai) {
                        if (any_addrinfos(&resolution_store)) continue;

                        if (no_in_progress_fds(arg->connection_attempt_fds, connection_attempt_fds_size) &&
                            resolution_store.is_all_finised) {
                            /* Use a different family local address if no choice, this
                             * will cause EAFNOSUPPORT. */
                            last_error = EAFNOSUPPORT;
                            rsock_syserr_fail_host_port(last_error, syscall, inetsock->local.host, inetsock->local.serv);
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
                        no_in_progress_fds(arg->connection_attempt_fds, connection_attempt_fds_size) ||
                        !resolution_store.is_all_finised) break;

                    if (local_status < 0) {
                        rsock_syserr_fail_host_port(last_error, syscall, inetsock->local.host, inetsock->local.serv);
                    }
                    rsock_syserr_fail_host_port(last_error, syscall, inetsock->remote.host, inetsock->remote.serv);
                }

                if (local_ai) {
                    #if !defined(_WIN32) && !defined(__CYGWIN__)
                    status = 1;
                    setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, (char*)&status, (socklen_t)sizeof(status));
                    #endif
                    status = bind(fd, local_ai->ai_addr, local_ai->ai_addrlen);
                    local_status = status;
                    syscall = "bind(2)";

                    if (status < 0) { // bind(2) に失敗
                        last_error = errno;
                        fd = -1;

                        if (any_addrinfos(&resolution_store)) continue;

                        if (!no_in_progress_fds(arg->connection_attempt_fds, connection_attempt_fds_size) ||
                            !resolution_store.is_all_finised) break;

                        if (local_status < 0) {
                           rsock_syserr_fail_host_port(last_error, syscall, inetsock->local.host, inetsock->local.serv);
                        }
                        rsock_syserr_fail_host_port(last_error, syscall, inetsock->remote.host, inetsock->remote.serv);
                    }
                }

                if (debug) printf("[DEBUG] %d: ** Start to connect to %d **\n", count, remote_ai->ai_family);
                syscall = "connect(2)";

                if (any_addrinfos(&resolution_store) ||
                    !no_in_progress_fds(arg->connection_attempt_fds, connection_attempt_fds_size) ||
                    !resolution_store.is_all_finised) {
                    socket_nonblock_set(fd);
                    status = connect(fd, remote_ai->ai_addr, remote_ai->ai_addrlen);
                    last_family = remote_ai->ai_family;
                } else {
                    if (!NIL_P(connect_timeout)) {
                        user_specified_connect_timeout_storage = rb_time_interval(connect_timeout);
                        user_specified_connect_timeout_at = &user_specified_connect_timeout_storage;
                    }

                    struct timeval *timeout =
                        (user_specified_connect_timeout_at && is_infinity(*user_specified_connect_timeout_at)) ?
                        NULL : user_specified_connect_timeout_at;
                    status = rsock_connect(fd, remote_ai->ai_addr, remote_ai->ai_addrlen, 0, timeout);
                }

                if (status == 0) { // 接続に成功
                    if (debug) printf("[DEBUG] %d: ** fd %d is connected successfully **\n", count, fd);
                    connected_fd = fd;
                    break;
                }

                if (errno == EINPROGRESS) { // 接続中
                    if (debug) printf("[DEBUG] %d: connection inprogress %d\n", count, fd);
                    if (current_capacity == connection_attempt_fds_size) {
                        int new_capacity = current_capacity + initial_capacity;
                        arg->connection_attempt_fds = (int*)realloc(arg->connection_attempt_fds, new_capacity * sizeof(int));
                        if (!arg->connection_attempt_fds) rb_syserr_fail(EAI_MEMORY, NULL);
                        current_capacity = new_capacity;
                        arg->connection_attempt_fds_capacity = current_capacity;
                    }
                    arg->connection_attempt_fds[connection_attempt_fds_size] = fd;
                    (connection_attempt_fds_size)++;
                    wait_arg.writefds = &writefds;

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
                        printf("[DEBUG] %d: connection attempt fd size %d\n", count, connection_attempt_fds_size);
                        for (int i = 0; i < connection_attempt_fds_size; i++) {
                            printf("[DEBUG] %d: connection attempt fd %d\n", count, arg->connection_attempt_fds[i]);
                        }
                    }
                    break;
                }

                if (debug) printf("[DEBUG] %d: connection failed\n", count);
                last_error = errno;
                close(fd);

                if (any_addrinfos(&resolution_store)) continue;

                if (!no_in_progress_fds(arg->connection_attempt_fds, connection_attempt_fds_size) ||
                    !resolution_store.is_all_finised) break;

                if (local_status < 0) {
                    rsock_syserr_fail_host_port(last_error, syscall, inetsock->local.host, inetsock->local.serv);
                }
                rsock_syserr_fail_host_port(last_error, syscall, inetsock->remote.host, inetsock->remote.serv);
            }
        }

        if (connected_fd >= 0) break;

        if (debug) printf("[DEBUG] %d: resolution_delay_expires_at %p\n", count, resolution_delay_expires_at);
        if (debug) printf("[DEBUG] %d: connection_attempt_delay_expires_at %p\n", count, connection_attempt_delay_expires_at);
        if (debug) printf("[DEBUG] %d: user_specified_resolv_timeout_at %p\n", count, user_specified_resolv_timeout_at);
        if (debug) printf("[DEBUG] %d: user_specified_connect_timeout_at %p\n", count, user_specified_connect_timeout_at);
        ends_at = select_expires_at(
            &resolution_store,
            resolution_delay_expires_at,
            connection_attempt_delay_expires_at,
            user_specified_resolv_timeout_at,
            user_specified_connect_timeout_at
        );
        if (ends_at) {
            if (debug) printf("[DEBUG] %d: ends_at->tv_sec %ld\n", count, ends_at->tv_sec);
            if (debug) printf("[DEBUG] %d: ends_at->tv_usec %d\n", count, ends_at->tv_usec);
            delay = tv_to_timeout(ends_at, now);
            wait_arg.delay = &delay;
        } else {
            wait_arg.delay = NULL;
        }

        if (debug) printf("[DEBUG] %d: ** Start to wait **\n", count);
        if (connection_attempt_fds_size) {
            FD_ZERO(wait_arg.writefds);
            int n = 0;
            for (int i = 0; i < connection_attempt_fds_size; i++) {
                int cfd = arg->connection_attempt_fds[i];
                if (cfd < 0) continue;
                if (cfd > n) n = cfd;
                FD_SET(cfd, wait_arg.writefds);
            }
            if (n > 0) n++;
            wait_arg.nfds = n;
        }

        if (!resolution_store.is_all_finised) {
            FD_ZERO(wait_arg.readfds);
            FD_SET(hostname_resolution_waiter, wait_arg.readfds);
            if ((hostname_resolution_waiter + 1) > wait_arg.nfds) {
                wait_arg.nfds = hostname_resolution_waiter + 1;
            }
        }

        rb_thread_call_without_gvl2(wait_happy_eyeballs_fds, &wait_arg, cancel_happy_eyeballs_fds, getaddrinfo_shared);
        rb_thread_check_ints();

        status = wait_arg.status;
        syscall = "select(2)";
        if (debug) printf("[DEBUG] %d: select(2) returned status %d\n", count, status);

        now = current_clocktime_ts();
        if (debug) printf("[DEBUG] %d: is_timeout_tv(resolution_delay_expires_at, now) %d\n", count, is_timeout_tv(resolution_delay_expires_at, now));
        if (is_timeout_tv(resolution_delay_expires_at, now)) {
            resolution_delay_expires_at = NULL;
        }
        if (debug) printf("[DEBUG] %d: is_timeout_tv(connection_attempt_delay_expires_at, now) %d\n", count, is_timeout_tv(connection_attempt_delay_expires_at, now));
        if (is_timeout_tv(connection_attempt_delay_expires_at, now)) {
            connection_attempt_delay_expires_at = NULL;
        }

        if (status < 0 && (errno && errno != EINTR)) rb_syserr_fail(errno, "select(2)");

        if (status > 0) {
            // 接続状態の確定
            for (int i = 0; i < connection_attempt_fds_size; i++) {
                fd = arg->connection_attempt_fds[i];
                if (fd < 0 || !FD_ISSET(fd, wait_arg.writefds)) continue;

                int err;
                socklen_t len = sizeof(err);

                if (getsockopt(fd, SOL_SOCKET, SO_ERROR, &err, &len) == 0) {
                    if (err == 0) { // success
                        if (debug) printf("[DEBUG] %d: fd %d is connected successfully\n", count, fd);
                        connected_fd = fd;
                        break;
                    }

                    // fail
                    if (debug) printf("[DEBUG] %d: fd %d is failed to connect\n", count, fd);
                    errno = err;
                    close(fd);
                    arg->connection_attempt_fds[i] = -1;
                    continue;
                }
            }

            if (connected_fd >= 0) break;
            last_error = errno;

            if (any_addrinfos(&resolution_store) ||
                !no_in_progress_fds(arg->connection_attempt_fds, connection_attempt_fds_size) ||
                !resolution_store.is_all_finised) {
                connection_attempt_delay_expires_at = NULL;
                if (no_in_progress_fds(arg->connection_attempt_fds, connection_attempt_fds_size)) {
                    user_specified_connect_timeout_at = NULL;
                }
            } else {
                if (local_status < 0) {
                    rsock_syserr_fail_host_port(last_error, syscall, inetsock->local.host, inetsock->local.serv);
                }
                rsock_syserr_fail_host_port(last_error, syscall, inetsock->remote.host, inetsock->remote.serv);
            }

            // 名前解決
            if (!resolution_store.is_all_finised && FD_ISSET(hostname_resolution_waiter, wait_arg.readfds)) {
                if (debug) printf("[DEBUG] %d: ** Hostname resolution finished **\n", count);
                while (true) {
                    resolved_type_size = read(hostname_resolution_waiter, resolved_type, sizeof(resolved_type) - 1);

                    if (resolved_type_size > 0) {
                        resolved_type[resolved_type_size] = '\0';

                        if (strcmp(resolved_type, IPV6_HOSTNAME_RESOLVED) == 0) { // IPv6解決
                            printf("[DEBUG] %d: ** Resolved IPv6 **\n", count);
                            resolution_store.v6.ai = arg->getaddrinfo_entries[IPV6_ENTRY_POS]->ai;
                            resolution_store.v6.finished = true;
                            if (arg->getaddrinfo_entries[IPV6_ENTRY_POS]->err) {
                                last_error = arg->getaddrinfo_entries[IPV6_ENTRY_POS]->err;
                                resolution_store.v6.succeed = false;
                            } else {
                                resolution_store.v6.succeed = true;
                            }
                            if (resolution_store.v4.finished) {
                                if (debug) printf("[DEBUG] %d: ** All hostname resolution is finished **\n", count);
                                resolution_store.is_all_finised = true;
                                wait_arg.readfds = NULL;
                                resolution_delay_expires_at = NULL;
                                user_specified_resolv_timeout_at = NULL;
                                break;
                            }
                        } else if (strcmp(resolved_type, IPV4_HOSTNAME_RESOLVED) == 0) { // IPv4解決
                            printf("[DEBUG] %d: ** Resolved IPv4 **\n", count);
                            resolution_store.v4.ai = arg->getaddrinfo_entries[IPV4_ENTRY_POS]->ai;
                            resolution_store.v4.finished = true;

                            if (arg->getaddrinfo_entries[IPV4_ENTRY_POS]->err) {
                                last_error = arg->getaddrinfo_entries[IPV4_ENTRY_POS]->err;
                                resolution_store.v4.succeed = false;
                            } else {
                                resolution_store.v4.succeed = true;
                            }

                            if (resolution_store.v6.finished) {
                                if (debug) printf("[DEBUG] %d: ** All hostname resolution is finished **\n", count);
                                resolution_store.is_all_finised = true;
                                wait_arg.readfds = NULL;
                                resolution_delay_expires_at = NULL;
                                user_specified_resolv_timeout_at = NULL;
                                break;
                            }
                        }
                    } else if (resolved_type_size == -1 && (errno == EAGAIN || errno == EWOULDBLOCK)) {
                        // TODO 頻繁にresolution_storeが空になっている。どの行が原因かどうかはわからない
                        // Exec format error - select(2) for "localhost" port 54703 (Errno::ENOEXEC)
                        if (debug) printf("[DEBUG] %d: ** hostname_resolution_waiter is now empty **\n", count);
                        errno = 0;
                        break;
                    } else {
                        if (debug) printf("[DEBUG] %d: ** Hostname Resolution may be failed **\n", count);
                        last_error = errno;
                        if (!any_addrinfos(&resolution_store) &&
                            no_in_progress_fds(arg->connection_attempt_fds, connection_attempt_fds_size) &&
                            resolution_store.is_all_finised) {
                            if (local_status < 0) {
                                rsock_syserr_fail_host_port(last_error, syscall, inetsock->local.host, inetsock->local.serv);
                            }
                            rsock_syserr_fail_host_port(last_error, syscall, inetsock->remote.host, inetsock->remote.serv);
                        }
                    }

                    if (!resolution_store.v6.finished && resolution_store.v4.succeed) {
                        if (debug) printf("[DEBUG] %d: Resolution Delay is ready\n", count);
                        set_timeout_tv(&resolution_delay_storage, 50, now);
                        resolution_delay_expires_at = &resolution_delay_storage;
                    }
                }
            }

            status = wait_arg.status = 0;
        }

        if (debug) printf("[DEBUG] %d: ** Check for exiting **\n", count);
        if (debug) printf("[DEBUG] %d: any_addrinfos %d\n", count, any_addrinfos(&resolution_store));
        if (!any_addrinfos(&resolution_store)) {
            if (debug) printf("[DEBUG] %d: no_in_progress_fds %d\n", count, no_in_progress_fds(arg->connection_attempt_fds, connection_attempt_fds_size));
            if (debug) printf("[DEBUG] %d: resolution_store.is_all_finised %d\n", count, resolution_store.is_all_finised);
            if (no_in_progress_fds(arg->connection_attempt_fds, connection_attempt_fds_size) && resolution_store.is_all_finised) {
                if (local_status < 0) {
                    rsock_syserr_fail_host_port(last_error, syscall, inetsock->local.host, inetsock->local.serv);
                }
                rsock_syserr_fail_host_port(last_error, syscall, inetsock->remote.host, inetsock->remote.serv);
            }

            if (debug) printf("[DEBUG] %d: user_specified_resolv_timeout_at %p\n", count, user_specified_resolv_timeout_at);
            if (debug) printf("[DEBUG] %d: is_timeout_tv(user_specified_resolv_timeout_at, now) %d\n", count, is_timeout_tv(user_specified_resolv_timeout_at, now));
            if (debug) printf("[DEBUG] %d: user_specified_connect_timeout_at %p\n", count, user_specified_connect_timeout_at);
            if (debug) printf("[DEBUG] %d: is_timeout_tv(user_specified_connect_timeout_at, now) %d\n", count, is_timeout_tv(user_specified_connect_timeout_at, now));
            if ((is_timeout_tv(user_specified_resolv_timeout_at, now) || resolution_store.is_all_finised) &&
                (is_timeout_tv(user_specified_connect_timeout_at, now) || no_in_progress_fds(arg->connection_attempt_fds, connection_attempt_fds_size))) {
                VALUE errno_module = rb_const_get(rb_cObject, rb_intern("Errno"));
                VALUE etimedout_error = rb_const_get(errno_module, rb_intern("ETIMEDOUT"));
                rb_raise(etimedout_error, "user specified timeout");
            }
        }
        if (debug && connection_attempt_fds_size > 0) {
            printf("[DEBUG] %d: connection attempt fds: ", count);
            for(int i = 0; i < connection_attempt_fds_size; i++) {
                printf("arg->connection_attempt_fds[%d]=%d, ", i, arg->connection_attempt_fds[i]);
            }
            printf("\n");
        }
        if (debug) puts("------------");
    }

    /* create new instance */
    return rsock_init_sock(inetsock->sock, connected_fd);
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

    for (int i = 0; i < arg->connection_attempt_fds_size; i++) {
        int connection_attempt_fd = arg->connection_attempt_fds[i];
        close(connection_attempt_fd);
    }

    free(arg->connection_attempt_fds);
    arg->connection_attempt_fds = NULL;

    return Qnil;
}

VALUE
rsock_init_inetsock(VALUE sock, VALUE remote_host, VALUE remote_serv,
                    VALUE local_host, VALUE local_serv, int type,
                    VALUE resolv_timeout, VALUE connect_timeout, VALUE fast_fallback,
                    VALUE test_mode_settings)
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
            inetsock_happy_resource.cancelled = false;

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
            inetsock_happy_resource.test_mode_settings = test_mode_settings;
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
    return rsock_init_inetsock(sock, hostname, port, Qnil, Qnil, INET_SERVER, Qnil, Qnil, Qfalse, Qnil); // 変更
}
```

```c
// ext/socket/sockssocket.c

static VALUE
socks_init(VALUE sock, VALUE host, VALUE port)
{
    // ...
    return rsock_init_inetsock(sock, hostname, port, Qnil, Qnil, INET_SERVER, Qnil, Qnil, Qfalse, Qnil); // 変更
}
```

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
    VALUE fast_fallback = Qtrue; // 追加
    VALUE test_mode_settings = Qnil; // 追加

    if (!keyword_ids[0]) {
        CONST_ID(keyword_ids[0], "resolv_timeout");
        CONST_ID(keyword_ids[1], "connect_timeout");
        CONST_ID(keyword_ids[2], "fast_fallback"); // 追加
        CONST_ID(keyword_ids[3], "test_mode_settings"); // 追加
    }

    rb_scan_args(argc, argv, "22:", &remote_host, &remote_serv,
                        &local_host, &local_serv, &opt);

    if (!NIL_P(opt)) {
        rb_get_kwargs(opt, keyword_ids, 0, 4, kwargs); // 変更
        if (kwargs[0] != Qundef) { resolv_timeout = kwargs[0]; }
        if (kwargs[1] != Qundef) { connect_timeout = kwargs[1]; }
        if (kwargs[2] != Qundef) { fast_fallback = kwargs[2]; } // 追加
        if (kwargs[3] != Qundef) { test_mode_settings = kwargs[3]; } // 追加
    }

    return rsock_init_inetsock(sock, remote_host, remote_serv,
                               local_host, local_serv, INET_CLIENT,
                               resolv_timeout, connect_timeout, fast_fallback,
                               test_mode_settings); // 追加
}
```
