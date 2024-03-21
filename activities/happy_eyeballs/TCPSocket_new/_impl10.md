# 2023/3/14-19
- (参照先: `getaddrinfo/_impl13`)
- 名前解決時に扱うリソースのうち、共通のものとスレッドごとに必要なものを分割した
- 条件によって不要なリソースを初期化しないようにした
- 構造体名などを整えた
- ロックのメモリ確保を動的に行うことで関数間で引き回すことができるようにした
- 引数にIPアドレスを指定した場合は不要なリソースを初期化しないようにした

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

enum sock_he_state {
    START,                /* 0 Start to hostname resolution */
    V4W,                  /* 1 Wait for Resolution Delay */
    V4C,                  /* 2 Start to connect with IPv4 addrinfo */
    V6C,                  /* 3 Start to connect with IPv4 addrinfo */
    V46C,                 /* 4 Start to connect with IPv6 addrinfo or IPv4addrinfo */
    V46W,                 /* 5 Wait for connecting with IPv6 addrinfo or IPv4addrinfo */
    SUCCESS,              /* 6 Connection established */
    FAILURE,              /* 7 Connection failed */
    TIMEOUT,              /* 8 Connection timed out */
};

static struct rb_getaddrinfo_happy_shared_resource *
create_rb_getaddrinfo_happy_shared_resource()
{
    struct rb_getaddrinfo_happy_shared_resource *shared;
    shared = (struct rb_getaddrinfo_happy_shared_resource *)calloc(1, sizeof(struct rb_getaddrinfo_happy_shared_resource));
    return shared;
}

static struct rb_getaddrinfo_happy_entry_resource *
allocate_rb_getaddrinfo_happy_entry_resource()
{
    struct rb_getaddrinfo_happy_entry_resource *entry;
    entry = (struct rb_getaddrinfo_happy_entry_resource *)calloc(1, sizeof(struct rb_getaddrinfo_happy_entry_resource));
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
    int status;
    int *nfds;
    fd_set *readfds, *writefds;
    struct timeval *delay;
};

static void *
wait_happy_eyeballs_fds(void *ptr)
{
    struct wait_happy_eyeballs_fds_arg *arg = (struct wait_happy_eyeballs_fds_arg *)ptr;
    int status;
    status = select(*arg->nfds, arg->readfds, arg->writefds, NULL, arg->delay);
    arg->status = status;
    return 0;
}

static void
close_fd(int fd)
{
    if (fd >= 0 && fcntl(fd, F_GETFL) != -1) close(fd);
}

struct cancel_happy_eyeballs_fds_arg
{
    int *cancelled, *connecting_fds, connecting_fds_size;
    rb_nativethread_lock_t *lock;
};

static void
cancel_happy_eyeballs_fds(void *ptr)
{
    struct cancel_happy_eyeballs_fds_arg *arg = (struct cancel_happy_eyeballs_fds_arg *)ptr;

    rb_nativethread_lock_lock(arg->lock);
    {
      *arg->cancelled = 1;
    }
    rb_nativethread_lock_unlock(arg->lock);

    for (int i = 0; i < arg->connecting_fds_size; i++) {
        int fd = arg->connecting_fds[i];
        close_fd(fd);
    }
    free(arg->connecting_fds);
    arg->connecting_fds = NULL;
}

static void
socket_nonblock_set(int fd)
{
    int flags = fcntl(fd, F_GETFL);
    if (flags == -1) {
        rb_sys_fail(0);
    }

    if ((flags & O_NONBLOCK) != 0) {
        return;
    } else {
        flags |= O_NONBLOCK;
    }

    if (fcntl(fd, F_SETFL, flags) == -1) {
        rb_sys_fail(0);
    }

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
    struct addrinfo *tmp_selected_ai = NULL;

    for (int i = 0; i < 2; i++) {
        if (precedences[i] == AF_INET6) {
            tmp_selected_ai = addrinfos->ip6_ai;
            if (tmp_selected_ai) {
                addrinfos->ip6_ai = tmp_selected_ai->ai_next;
                break;
            }
        } else {
            tmp_selected_ai = addrinfos->ip4_ai;
            if (tmp_selected_ai) {
                addrinfos->ip4_ai = tmp_selected_ai->ai_next;
                break;
            }
        }
    }
    return tmp_selected_ai;
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
        if (fds[i] > 0) return FALSE;
    }
    return TRUE;
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
    struct rb_getaddrinfo_happy_entry_resource *getaddrinfo_entries[2];
    struct rb_getaddrinfo_happy_shared_resource *getaddrinfo_shared;
    int connecting_fds_size, connecting_fds_capacity, connected_fd;
    int *connecting_fds;
};

static VALUE
init_inetsock_internal_happy(VALUE v)
{
    struct inetsock_happy_arg *arg = (void *)v;
    struct inetsock_arg *inetsock_resource = arg->inetsock_resource;
    struct addrinfo *remote_ai = NULL, *local_ai = NULL;
    int fd, last_error = 0, status = 0, local_status = 0;
    const char *syscall = 0;

    VALUE resolv_timeout = inetsock_resource->resolv_timeout;
    VALUE connect_timeout = inetsock_resource->connect_timeout;
    struct timeval resolv_timeout_tv_storage;
    struct timeval *resolv_timeout_tv = NULL;
    struct timespec resolution_expires_at_ts;
    struct timeval connect_timeout_tv_storage;
    struct timeval *connect_timeout_tv = NULL;
    struct timespec connect_timeout_ts;

    if (!NIL_P(resolv_timeout)) {
        resolv_timeout_tv_storage = rb_time_interval(resolv_timeout);
        resolv_timeout_tv = &resolv_timeout_tv_storage;
    }
    if (!NIL_P(connect_timeout)) {
        connect_timeout_tv_storage = rb_time_interval(connect_timeout);
        connect_timeout_tv = &connect_timeout_tv_storage;
    }

    int remote_addrinfo_hints = 0;

    #ifdef HAVE_CONST_AI_ADDRCONFIG
    remote_addrinfo_hints |= AI_ADDRCONFIG;
    #endif

    struct rb_getaddrinfo_happy_shared_resource *getaddrinfo_shared = arg->getaddrinfo_shared;
    int families_size = arg->families_size;

    int wait_resolution_pipe, notify_resolution_pipe;
    int pipefd[2];

    struct wait_happy_eyeballs_fds_arg wait_arg;
    struct cancel_happy_eyeballs_fds_arg cancel_arg;
    int cancelled = 0;

    pthread_t threads[families_size];
    char resolved_type[2];
    ssize_t resolved_type_size;

    fd_set readfds, writefds;
    int nfds;

    pipe(pipefd);
    wait_resolution_pipe = pipefd[IPV6_ENTRY_POS];
    notify_resolution_pipe = pipefd[IPV4_ENTRY_POS];
    FD_ZERO(&readfds);
    FD_ZERO(&writefds);
    getaddrinfo_shared->node = strdup(arg->hostp);
    getaddrinfo_shared->service = strdup(arg->portp);
    getaddrinfo_shared->refcount = families_size + 1;
    getaddrinfo_shared->notify = notify_resolution_pipe;
    getaddrinfo_shared->wait = wait_resolution_pipe;
    getaddrinfo_shared->cancelled = &cancelled;
    rb_nativethread_lock_initialize(getaddrinfo_shared->lock);

    wait_arg.readfds = &readfds;
    wait_arg.writefds = &writefds;
    wait_arg.nfds = &nfds;
    wait_arg.delay = NULL;

    cancel_arg.cancelled = &cancelled;
    cancel_arg.lock = getaddrinfo_shared->lock;
    cancel_arg.connecting_fds = arg->connecting_fds;
    cancel_arg.connecting_fds_size = arg->connecting_fds_size;

    struct rb_getaddrinfo_happy_entry_resource *tmp_getaddrinfo_entry = NULL;
    struct resolved_addrinfos selectable_addrinfos = { NULL, NULL };
    struct addrinfo *tmp_selected_ai;

    int connecting_fds_size = arg->connecting_fds_size;
    int initial_capacity = 10;
    int current_capacity = initial_capacity;
    int new_capacity;

    arg->connecting_fds = (int *)malloc(initial_capacity * sizeof(int));
    if (!arg->connecting_fds) rb_syserr_fail(EAI_MEMORY, NULL);
    arg->connecting_fds_capacity = initial_capacity;

    struct timeval resolution_delay;
    struct timeval connection_attempt_delay;
    struct timespec connection_attempt_delay_expires_at;
    struct timespec connection_attempt_started_at_ts = { -1, -1 };

    int state = START;
    int is_resolution_finished = FALSE;
    int stop = 0, last_family = 0;

    ID sleep_param = rb_intern("@sleep_before_hostname_resolution");
    VALUE klass = rb_path2class("TCPSocket");
    int sleep_before_hostname_resolution = false;
    useconds_t sleep_ts[families_size];

    if (rb_ivar_defined(klass, sleep_param)) {
        VALUE sleep_param_settings = rb_ivar_get(klass, sleep_param);

        if (RB_TYPE_P(sleep_param_settings, T_HASH)) {
            sleep_before_hostname_resolution = true;
            VALUE ipv6_param_key = ID2SYM(rb_intern("ipv6"));
            VALUE ipv4_param_key = ID2SYM(rb_intern("ipv4"));
            VALUE ipv6_param_value = rb_hash_aref(sleep_param_settings, ipv6_param_key);
            VALUE ipv4_param_value = rb_hash_aref(sleep_param_settings, ipv4_param_key);

            sleep_ts[0] = (useconds_t)(FIX2INT(ipv6_param_value) * 1000);
            sleep_ts[1] = (useconds_t)(FIX2INT(ipv4_param_value) * 1000);
        }
    }

    while (!stop) {
        //printf("\nstate %d\n", state);
        switch (state) {
            case START:
            {
                /*
                 * Maybe also accept a local address
                 */
                // local_host / local_portが指定された場合
                if (!NIL_P(inetsock_resource->local.host) || !NIL_P(inetsock_resource->local.serv)) {
                    inetsock_resource->local.res = rsock_addrinfo(
                        inetsock_resource->local.host,
                        inetsock_resource->local.serv,
                        AF_UNSPEC,
                        SOCK_STREAM,
                        0
                    );
                }

                // getaddrinfoの実行
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

                    if (sleep_before_hostname_resolution) {
                        arg->getaddrinfo_entries[i]->sleep = sleep_ts[i];
                    }

                    if (do_pthread_create(&threads[i], do_rb_getaddrinfo_happy, arg->getaddrinfo_entries[i]) != 0) {
                        last_error = EAI_AGAIN;
                        state = FAILURE;
                        break;
                    }
                    pthread_detach(threads[i]);
                }

                if (last_error) continue;
                int resolution_retry_count = families_size - 1;

                while (resolution_retry_count >= 0) {
                    if (resolv_timeout_tv) {
                        wait_arg.delay = resolv_timeout_tv;
                        resolution_expires_at_ts = resolv_timeout_expires_at_ts(*resolv_timeout_tv);
                    }

                    FD_ZERO(&readfds);
                    FD_SET(wait_resolution_pipe, &readfds);
                    nfds = wait_resolution_pipe + 1;
                    rb_thread_call_without_gvl2(wait_happy_eyeballs_fds, &wait_arg, cancel_happy_eyeballs_fds, &cancel_arg);
                    status = wait_arg.status;
                    syscall = "select(2)";

                    if (status == 0) { // resolv_timeout
                        state = TIMEOUT;
                        break;
                    } else if (status < 0) {
                        rb_syserr_fail(errno, "select(2)");
                    }

                    resolved_type_size = read(wait_resolution_pipe, resolved_type, sizeof(resolved_type) - 1);
                    if (resolved_type_size < 0) {
                        last_error = errno;
                        state = FAILURE;
                        break;
                    }
                    resolved_type[resolved_type_size] = '\0';

                    if (strcmp(resolved_type, IPV6_HOSTNAME_RESOLVED) == 0) {
                        tmp_getaddrinfo_entry = arg->getaddrinfo_entries[IPV6_ENTRY_POS];
                        selectable_addrinfos.ip6_ai = tmp_getaddrinfo_entry->ai;
                    } else if (strcmp(resolved_type, IPV4_HOSTNAME_RESOLVED) == 0) {
                        tmp_getaddrinfo_entry = arg->getaddrinfo_entries[IPV4_ENTRY_POS];
                        selectable_addrinfos.ip4_ai = tmp_getaddrinfo_entry->ai;
                    }

                    if (tmp_getaddrinfo_entry->err != 0) {
                        if (tmp_getaddrinfo_entry->err != EAI_ADDRFAMILY) {
                            last_error = tmp_getaddrinfo_entry->err;
                        }

                        resolution_retry_count--;

                        if (resolution_retry_count == 0) {
                            state = FAILURE;
                            break;
                        }
                    } else {
                        if (tmp_getaddrinfo_entry->family == AF_INET6) {
                            state = V6C;
                        } else if (tmp_getaddrinfo_entry->family == AF_INET) {
                            if (arg->getaddrinfo_entries[IPV6_ENTRY_POS]->err) { // v6の名前解決に失敗している場合
                                FD_ZERO(&readfds);
                                wait_arg.readfds = NULL;
                                is_resolution_finished = TRUE;
                                state = V4C;
                            } else { // v6の名前解決が終わっていない場合
                                state = V4W;
                            }
                        }
                        break;
                    }
                }
                status = wait_arg.status = 0;
                continue;
            }

            case V4W:
            {
                resolution_delay.tv_sec = 0;
                resolution_delay.tv_usec = RESOLUTION_DELAY_USEC;
                wait_arg.delay = &resolution_delay;
                FD_ZERO(&readfds);
                FD_SET(wait_resolution_pipe, &readfds);
                nfds = wait_resolution_pipe + 1;
                rb_thread_call_without_gvl2(wait_happy_eyeballs_fds, &wait_arg, cancel_happy_eyeballs_fds, &cancel_arg);
                status = wait_arg.status;
                syscall = "select(2)";

                if (status == 0) {
                    state = V4C;
                    continue;
                } else if (status < 0) {
                    rb_syserr_fail(errno, "select(2)");
                }

                // 名前解決できた
                resolved_type_size = read(wait_resolution_pipe, resolved_type, sizeof(resolved_type) - 1);
                status = wait_arg.status = 0;

                if (resolved_type_size < 0) {
                    last_error = errno;
                    state = FAILURE;
                    continue;
                }

                selectable_addrinfos.ip6_ai = arg->getaddrinfo_entries[IPV6_ENTRY_POS]->ai;
                FD_ZERO(&readfds);
                wait_arg.readfds = NULL;
                is_resolution_finished = TRUE;
                state = V46C;
                continue;
            }

            case V6C:
            case V4C:
            case V46C:
            {
                if (connection_attempt_started_at_ts.tv_sec == -1 &&
                    connection_attempt_started_at_ts.tv_nsec == -1) {
                    connection_attempt_started_at_ts = current_clocktime_ts();
                }

                tmp_selected_ai = select_addrinfo(&selectable_addrinfos, last_family);

                if (tmp_selected_ai) {
                    inetsock_resource->fd = fd = -1;
                    remote_ai = tmp_selected_ai;
                } else { // 接続可能なaddrinfoが見つからなかった
                    if (is_connecting_fds_empty(arg->connecting_fds, connecting_fds_size) &&
                        is_resolution_finished) {
                        state = FAILURE;
                    } else {
                        if (resolv_timeout_tv &&
                            !is_resolution_finished &&
                            is_timeout(resolution_expires_at_ts)) {
                            state = TIMEOUT;
                        } else {
                            state = V46W;
                        }
                    }
                    continue;
                }

                #if !defined(INET6) && defined(AF_INET6)
                if (remote_ai->ai_family == AF_INET6)
                    inetsock_resource->fd = fd = -1;

                    if (!(selectable_addrinfos.ip6_ai || selectable_addrinfos.ip4_ai) &&
                        is_connecting_fds_empty(arg->connecting_fds, connecting_fds_size) &&
                        is_resolution_finished) {
                        state = FAILURE;
                    } else if (selectable_addrinfos.ip6_ai || selectable_addrinfos.ip4_ai) {
                        // Try other addrinfo in next loop
                        last_family = AF_INET6;
                    } else {
                        if (resolv_timeout_tv &&
                            !is_resolution_finished &&
                            is_timeout(resolution_expires_at_ts)) {
                            state = TIMEOUT;
                        } else {
                            // Wait for connection to be established or hostname resolution in next loop
                            connection_attempt_delay_expires_at = (struct timespec){ -1, -1 };
                            state = V46W;
                        }
                    }
                    continue;
                #endif

                local_ai = NULL;

                if (inetsock_resource->local.res) { // local_addrinfos.any?
                    for (local_ai = inetsock_resource->local.res->ai; local_ai; local_ai = local_ai->ai_next) {
                        if (local_ai->ai_family == remote_ai->ai_family)
                            break;
                    }
                    if (!local_ai) {
                        if (!(selectable_addrinfos.ip6_ai || selectable_addrinfos.ip4_ai) &&
                            is_connecting_fds_empty(arg->connecting_fds, connecting_fds_size) &&
                            is_resolution_finished) {
                            // 試せるリモートaddrinfoが存在しないことが確定している
                            /* Use a different family local address if no choice, this
                             * will cause EAFNOSUPPORT. */
                            last_error = EAFNOSUPPORT;
                            state = FAILURE;
                        } else if (selectable_addrinfos.ip6_ai || selectable_addrinfos.ip4_ai) {
                            // Try other addrinfo in next loop
                        } else {
                            if (resolv_timeout_tv &&
                                !is_resolution_finished &&
                                is_timeout(resolution_expires_at_ts)) {
                                state = TIMEOUT;
                            } else {
                                // Wait for connection to be established or hostname resolution in next loop
                                connection_attempt_delay_expires_at = (struct timespec){ -1, -1 };
                                state = V46W;
                            }
                        }
                        continue;
                    }
                }

                status = rsock_socket(remote_ai->ai_family, remote_ai->ai_socktype, remote_ai->ai_protocol);
                syscall = "socket(2)";
                fd = status;

                if (fd < 0) { // socket(2)に失敗
                    last_error = errno;
                    inetsock_resource->fd = fd = -1;

                    if (!(selectable_addrinfos.ip6_ai || selectable_addrinfos.ip4_ai) &&
                        is_connecting_fds_empty(arg->connecting_fds, connecting_fds_size) &&
                        is_resolution_finished) {
                        state = FAILURE;
                    } else if (selectable_addrinfos.ip6_ai || selectable_addrinfos.ip4_ai) {
                        // Try other addrinfo in next loop
                    } else {
                        if (resolv_timeout_tv &&
                            !wait_resolution_pipe &&
                            is_timeout(resolution_expires_at_ts)) {
                            state = TIMEOUT;
                        } else {
                            // Wait for connection to be established or hostname resolution in next loop
                            connection_attempt_delay_expires_at = (struct timespec){ -1, -1 };
                            state = V46W;
                        }
                    }
                    continue;
                }

                inetsock_resource->fd = fd;

                if (local_ai) {
                    #if !defined(_WIN32) && !defined(__CYGWIN__)
                    status = 1;
                    setsockopt(fd, SOL_SOCKET, SO_REUSEADDR,
                               (char*)&status, (socklen_t)sizeof(status));
                    #endif
                    status = bind(fd, local_ai->ai_addr, local_ai->ai_addrlen);
                    local_status = status;
                    syscall = "bind(2)";

                    if (status < 0) { // bind(2) に失敗
                        last_error = errno;
                        inetsock_resource->fd = fd = -1;

                        if (!(selectable_addrinfos.ip6_ai || selectable_addrinfos.ip4_ai) &&
                            is_connecting_fds_empty(arg->connecting_fds, connecting_fds_size) &&
                            is_resolution_finished) {
                            state = FAILURE;
                        } else if (selectable_addrinfos.ip6_ai || selectable_addrinfos.ip4_ai) {
                            // Try other addrinfo in next loop
                        } else {
                            if (resolv_timeout_tv &&
                                !is_resolution_finished &&
                                is_timeout(resolution_expires_at_ts)) {
                                state = TIMEOUT;
                            } else {
                                // Wait for connection to be established or hostname resolution in next loop
                                connection_attempt_delay_expires_at = (struct timespec){ -1, -1 };
                                state = V46W;
                            }
                        }
                        continue;
                    }
                }

                connection_attempt_delay_expires_at = connection_attempt_delay_expires_at_ts();
                socket_nonblock_set(fd);
                status = connect(fd, remote_ai->ai_addr, remote_ai->ai_addrlen);
                syscall = "connect(2)";

                last_family = remote_ai->ai_family;

                if (status == 0) { // 接続に成功
                    state = SUCCESS;
                } else if (errno == EINPROGRESS) { // 接続中
                    if (current_capacity == connecting_fds_size) {
                        new_capacity = current_capacity + initial_capacity;
                        arg->connecting_fds = (int*)realloc(arg->connecting_fds, new_capacity * sizeof(int));
                        if (!arg->connecting_fds) rb_syserr_fail(EAI_MEMORY, NULL);
                        current_capacity = new_capacity;
                        arg->connecting_fds_capacity = current_capacity;
                    }
                    arg->connecting_fds[connecting_fds_size] = fd;
                    (connecting_fds_size)++;
                    state = V46W;
                } else { // connect(2)に失敗
                    last_error = errno;
                    close_fd(fd);
                    inetsock_resource->fd = fd = -1;

                    if (!(selectable_addrinfos.ip6_ai || selectable_addrinfos.ip4_ai) &&
                        is_connecting_fds_empty(arg->connecting_fds, connecting_fds_size) &&
                        is_resolution_finished) {
                        state = FAILURE;
                    } else if (selectable_addrinfos.ip6_ai || selectable_addrinfos.ip4_ai) {
                        // Try other addrinfo in next loop
                    } else {
                        if (resolv_timeout_tv &&
                            !is_resolution_finished &&
                            is_timeout(resolution_expires_at_ts)) {
                            state = TIMEOUT;
                        } else {
                            // Wait for connection to be established or hostname resolution in next loop
                            connection_attempt_delay_expires_at = (struct timespec){ -1, -1 };
                            state = V46W;
                        }
                    }
                }
                continue;
            }

            case V46W:
            {
                if (connect_timeout_tv) {
                    connect_timeout_ts = add_timeval_to_timespec(*connect_timeout_tv, connection_attempt_started_at_ts);
                    if (is_timeout(connect_timeout_ts) == 0) {
                        state = TIMEOUT;
                        continue;
                    }
                }

                connection_attempt_delay.tv_sec = 0;
                connection_attempt_delay.tv_usec = (int)usec_to_timeout(connection_attempt_delay_expires_at);
                wait_arg.delay = &connection_attempt_delay;

                nfds = initialize_write_fds(arg->connecting_fds, connecting_fds_size, &writefds);

                if (!is_resolution_finished) {
                    FD_ZERO(&readfds);
                    FD_SET(wait_resolution_pipe, &readfds);
                    if ((wait_resolution_pipe + 1) > nfds) nfds = wait_resolution_pipe + 1;
                }

                rb_thread_call_without_gvl2(wait_happy_eyeballs_fds, &wait_arg, cancel_happy_eyeballs_fds, &cancel_arg);
                status = wait_arg.status;
                syscall = "select(2)";

                if (status > 0) {
                    if (!is_resolution_finished && FD_ISSET(wait_resolution_pipe, &readfds)) { // 名前解決できた
                        resolved_type_size = read(wait_resolution_pipe, resolved_type, sizeof(resolved_type) - 1);
                        resolved_type[resolved_type_size] = '\0';

                        if (strcmp(resolved_type, IPV6_HOSTNAME_RESOLVED) == 0) {
                            selectable_addrinfos.ip6_ai = arg->getaddrinfo_entries[IPV6_ENTRY_POS]->ai;
                            tmp_getaddrinfo_entry = arg->getaddrinfo_entries[IPV6_ENTRY_POS];
                        } else if (strcmp(resolved_type, IPV4_HOSTNAME_RESOLVED) == 0) {
                            selectable_addrinfos.ip4_ai = arg->getaddrinfo_entries[IPV4_ENTRY_POS]->ai;
                            tmp_getaddrinfo_entry = arg->getaddrinfo_entries[IPV4_ENTRY_POS];
                        }

                        FD_ZERO(&readfds);
                        wait_arg.readfds = NULL;
                        is_resolution_finished = TRUE;
                    } else { // writefdsに書き込み可能ソケットができた
                        inetsock_resource->fd = fd = find_connected_socket(arg->connecting_fds, connecting_fds_size, &writefds);
                        if (fd >= 0) {
                            state = SUCCESS;
                        } else {
                            last_error = errno;
                            close_fd(fd);
                            inetsock_resource->fd = fd = -1;

                            if (!(selectable_addrinfos.ip6_ai || selectable_addrinfos.ip4_ai) &&
                                is_connecting_fds_empty(arg->connecting_fds, connecting_fds_size) &&
                                is_resolution_finished) {
                                state = FAILURE;
                            } else if (selectable_addrinfos.ip6_ai || selectable_addrinfos.ip4_ai) {
                                // Wait for connection attempt delay in next loop
                            } else {
                                if (resolv_timeout_tv &&
                                    !is_resolution_finished &&
                                    is_timeout(resolution_expires_at_ts)) {
                                    state = TIMEOUT;
                                } else {
                                    // Wait for connection to be established or hostname resolution in next loop
                                    connection_attempt_delay_expires_at = (struct timespec){ -1, -1 };
                                }
                            }
                        }
                    }
                } else if (status == 0) { // Connection Attempt Delay timeout
                    if (!(selectable_addrinfos.ip6_ai || selectable_addrinfos.ip4_ai) &&
                        is_connecting_fds_empty(arg->connecting_fds, connecting_fds_size) &&
                        is_resolution_finished) {
                        state = FAILURE;
                    } else if (selectable_addrinfos.ip6_ai || selectable_addrinfos.ip4_ai) {
                        // Try other Addrinfo in next loop
                        state = V46C;
                    } else {
                        if (resolv_timeout_tv &&
                            !is_resolution_finished &&
                            is_timeout(resolution_expires_at_ts)) {
                            state = TIMEOUT;
                        } else {
                            // Wait for connection to be established or hostname resolution in next loop
                            connection_attempt_delay_expires_at = (struct timespec){ -1, -1 };
                        }
                    }
                } else { // selectに失敗
                    rb_syserr_fail(errno, "select(2)");
                }
                status = wait_arg.status = 0;
                continue;
            }

            case SUCCESS:
                stop = 1;
                continue;

            case FAILURE:
            {
                VALUE host, port;

                if (local_status < 0) { // local_host / local_portが指定されており、ローカルに接続可能なアドレスファミリがなかった場合
                    host = inetsock_resource->local.host;
                    port = inetsock_resource->local.serv;
                } else {
                    host = inetsock_resource->remote.host;
                    port = inetsock_resource->remote.serv;
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

    arg->connected_fd = inetsock_resource->fd;
    inetsock_resource->fd = -1;

    /* create new instance */
    return rsock_init_sock(inetsock_resource->sock, fd);
}

static VALUE
inetsock_cleanup_happy(VALUE v)
{
    struct inetsock_happy_arg *arg = (void *)v;
    struct inetsock_arg *inetsock_resource = arg->inetsock_resource;
    struct rb_getaddrinfo_happy_shared_resource *getaddrinfo_shared = arg->getaddrinfo_shared;

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

    int shared_need_free = 0;
    int need_free[2] = { 0, 0 };
    rb_nativethread_lock_lock(getaddrinfo_shared->lock);
    {
        for (int i = 0; i < arg->families_size; i++) {
            if (arg->getaddrinfo_entries[i] && --(arg->getaddrinfo_entries[i]->refcount) == 0) {
                need_free[i] = 1;
            }
        }
        if (--(getaddrinfo_shared->refcount) == 0) {
            shared_need_free = 1;
        }
    }
    rb_nativethread_lock_unlock(getaddrinfo_shared->lock);

    for (int i = 0; i < arg->families_size; i++) {
        if (need_free[i]) free_rb_getaddrinfo_happy_entry_resource(&arg->getaddrinfo_entries[i]);
    }
    if (shared_need_free) free_rb_getaddrinfo_happy_shared_resource(&getaddrinfo_shared);

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
    // TODO struct rb_getaddrinfo_happy_shared_resourceのint *cancelledをbool chancelledにする
    // TODO free_rb_getaddrinfo_happy_shared_resourceとwait_happy_eyeballs_fds_argとcancel_happy_eyeballs_fds_argは1つの構造体に統合
    // TODO init_inetsock_internal_happyのint cancelled = 0はrsock_init_inetsockから渡す
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

            inetsock_happy_resource.getaddrinfo_shared = create_rb_getaddrinfo_happy_shared_resource();
            if (!inetsock_happy_resource.getaddrinfo_shared) rb_syserr_fail(EAI_MEMORY, NULL);

            inetsock_happy_resource.getaddrinfo_shared->lock = malloc(sizeof(rb_nativethread_lock_t));
            if (!inetsock_happy_resource.getaddrinfo_shared->lock) rb_syserr_fail(EAI_MEMORY, NULL);

            for (int i = 0; i < inetsock_happy_resource.families_size; i++) {
                inetsock_happy_resource.getaddrinfo_entries[i] = allocate_rb_getaddrinfo_happy_entry_resource();
                if (!(inetsock_happy_resource.getaddrinfo_entries[i])) rb_syserr_fail(EAI_MEMORY, NULL);
                inetsock_happy_resource.getaddrinfo_entries[i]->shared = inetsock_happy_resource.getaddrinfo_shared;
            }

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
