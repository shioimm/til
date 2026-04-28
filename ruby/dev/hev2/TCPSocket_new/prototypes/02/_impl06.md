# 2023/2/23-3/1
- (参照先: `getaddrinfo/_impl10`)
- 終了処理を適切にする
- 名前解決失敗時のメモリ解放を適切に行う
- start時点での名前解決時に`EAI_ADDRFAMILY`が発生した場合、ユーザに返すエラーとしては保持しない
- IPアドレス指定

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

static void allocate_rb_getaddrinfo_happy_entry(struct rb_getaddrinfo_happy_entry **entry, const char *portp, size_t *portp_offset)
{
    if (!entry || !portp_offset) return;

    size_t getaddrinfo_entry_bufsize = sizeof(struct rb_getaddrinfo_happy_entry) + (*portp_offset) + (portp ? strlen(portp) + 1 : 0);
    *entry = (struct rb_getaddrinfo_happy_entry *)malloc(getaddrinfo_entry_bufsize);
    if (!(*entry)) {
        rb_gc();
        *entry = (struct rb_getaddrinfo_happy_entry *)malloc(getaddrinfo_entry_bufsize);
    }
    if (*entry) {
        memset(*entry, 0, getaddrinfo_entry_bufsize); // 確保したメモリをゼロで初期化
    }
}

static void
allocate_rb_getaddrinfo_happy_entry_endpoint(char **endpoint, const char *source, size_t *offset, char *buf)
{
    if (source) {
        *endpoint = buf + *offset;
        strcpy(*endpoint, source);
    } else {
        *endpoint = NULL;
    }
}

static void allocate_rb_getaddrinfo_happy_entry_hints(struct addrinfo *hints, int family, int remote_addrinfo_hints, int additional_flags)
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
    int *cancelled, *connecting_fds, *connecting_fds_size;
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

    for (int i = 0; i < *(arg->connecting_fds_size); i++) {
        int fd = arg->connecting_fds[i];
        close_fd(fd);
    }
    free(arg->connecting_fds);
}

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
set_connecting_fds(const int *fds, int fds_size, fd_set *set)
{
    int nfds = 0;
    FD_ZERO(set);

    for (int i = 0; i < fds_size; i++) {
        int fd = fds[i];
        if (fd < 0) continue;
        if (fd > nfds) nfds = fd;
        FD_SET(fd, set);
    }

    nfds++;
    return nfds;
}

static int
find_connected_socket(int *fds, int fds_size, fd_set *writefds)
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
                        fds[i] = -1;
                        return fd;
                    case EINPROGRESS: // operation in progress
                        break;
                    default: // fail
                        errno = error;
                        close_fd(fd);
                        fds[i] = -1;
                        break;
                }
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

static int
is_hostname_resolution_finished(int hostname_resolution_waiting)
{
    if (fcntl(hostname_resolution_waiting, F_GETFL) == -1 && errno == EBADF) {
        return TRUE;
    }
    return FALSE;
}


int specified_address_family(const char *hostname, int *specified_family)
{
    struct in_addr ipv4addr;
    struct in6_addr ipv6addr;

    if (inet_pton(AF_INET6, hostname, &ipv6addr)) {
        *specified_family = AF_INET6;
        return TRUE;
    } else if (inet_pton(AF_INET, hostname, &ipv4addr)) {
        *specified_family = AF_INET;
        return TRUE;
    }

    return FALSE;
}

struct inetsock_happy_arg
{
    struct inetsock_arg *inetsock_resource;
    rb_nativethread_lock_t *lock;
    int hostname_resolution_waiting, hostname_resolution_notifying;
    int *need_frees[2];
    struct rb_getaddrinfo_happy_entry *getaddrinfo_entries[2];
    int *connecting_fds_size;
    int *connecting_fds_capacity;
    int *connecting_fds;
    int *connected_fd;
};

static VALUE
init_inetsock_internal_happy(VALUE v)
{
    struct inetsock_happy_arg *arg = (void *)v;
    struct inetsock_arg *inetsock_resource = arg->inetsock_resource;
    int last_error = 0;
    struct addrinfo *remote_ai = NULL;
    struct addrinfo *local_ai;
    int fd, status = 0, local = 0;
    const char *syscall = 0;
    VALUE resolv_timeout = inetsock_resource->resolv_timeout;
    VALUE connect_timeout = inetsock_resource->connect_timeout;
    struct timeval resolv_timeout_tv_storage;
    struct timeval *resolv_timeout_tv = NULL;
    struct timespec hostname_resolution_expires_at_ts;
    struct timeval connect_timeout_tv_storage;
    struct timeval *connect_timeout_tv = NULL;
    struct timespec connect_timeout_ts;
    int remote_addrinfo_hints = 0;

    if (!NIL_P(resolv_timeout)) {
        resolv_timeout_tv_storage = rb_time_interval(resolv_timeout);
        resolv_timeout_tv = &resolv_timeout_tv_storage;
    }
    if (!NIL_P(connect_timeout)) {
        connect_timeout_tv_storage = rb_time_interval(connect_timeout);
        connect_timeout_tv = &connect_timeout_tv_storage;
    }

    #ifdef HAVE_CONST_AI_ADDRCONFIG
    remote_addrinfo_hints |= AI_ADDRCONFIG;
    #endif

    // do_rb_getaddrinfo_happyに渡す引数の準備
    char *hostp, *portp;
    char hbuf[NI_MAXHOST], pbuf[NI_MAXSERV];
    int additional_flags = 0;
    hostp = host_str(inetsock_resource->remote.host, hbuf, sizeof(hbuf), &additional_flags);
    portp = port_str(inetsock_resource->remote.serv, pbuf, sizeof(pbuf), &additional_flags);
    size_t hostp_offset = sizeof(struct rb_getaddrinfo_happy_entry);
    size_t portp_offset = hostp_offset + (hostp ? strlen(hostp) + 1 : 0);

    int hostname_resolution_waiting = arg->hostname_resolution_waiting;
    int hostname_resolution_notifying = arg->hostname_resolution_notifying;
    rb_nativethread_lock_t *lock = arg->lock;
    int cancelled = 0;

    int families[2] = { AF_INET6, AF_INET };

    int *tmp_need_free = NULL;
    struct rb_getaddrinfo_happy_entry *tmp_getaddrinfo_entry = NULL;
    struct addrinfo getaddrinfo_hints[2];

    pthread_t threads[2];
    char written[2];
    ssize_t bytes_read;

    int *connecting_fds_size = arg->connecting_fds_size;
    int initial_capacity = 10; // TODO 動的に増やすための関数を用意する
    arg->connecting_fds = (int *)malloc(initial_capacity * sizeof(int));
    if (!arg->connecting_fds) {
        perror("Failed to allocate memory");
        return -1;
    }
    *arg->connecting_fds_capacity = initial_capacity;

    fd_set readfds, writefds;
    int nfds;
    struct timeval resolution_delay;
    struct timeval connection_attempt_delay;
    struct timespec connection_attempt_delay_expires_at;
    struct timespec connection_attempt_started_at_ts = { -1, -1 };

    struct wait_happy_eyeballs_fds_arg wait_arg;
    wait_arg.readfds = &readfds;
    wait_arg.writefds = &writefds;
    wait_arg.nfds = &nfds;
    wait_arg.delay = NULL;

    struct cancel_happy_eyeballs_fds_arg cancel_arg;
    cancel_arg.cancelled = &cancelled;
    cancel_arg.lock = lock;
    cancel_arg.connecting_fds = arg->connecting_fds;
    cancel_arg.connecting_fds_size = connecting_fds_size;

    int last_family = 0;
    struct resolved_addrinfos selectable_addrinfos = { NULL, NULL };
    struct addrinfo *tmp_selected_ai;

    int stop = 0;
    int state = START;

    // TODO 05 各ステートの分岐条件に取りこぼしがないか確認 (たまにステートの遷移がおかしい気がするので調査する)
    while (!stop) {
        printf("\nstate %d\n", state);
        switch (state) {
            case START:
            {
                int specified_family;
                int is_host_specified_address = specified_address_family(hostp, &specified_family);

                if (is_host_specified_address) {
                    struct addrinfo *ai;
                    struct addrinfo hints; // WIP

                    MEMZERO(&hints, struct addrinfo, 1);
                    hints.ai_family = specified_family;
                    hints.ai_socktype = SOCK_STREAM;
                    hints.ai_protocol = IPPROTO_TCP;
                    hints.ai_flags = remote_addrinfo_hints;
                    hints.ai_flags |= additional_flags;

                    last_error = getaddrinfo(hostp, portp, &hints , &ai);

                    if (last_error != 0) {
                        state = FAILURE;
                        continue;
                    }

                    if (specified_family == AF_INET6) {
                        selectable_addrinfos.ip6_ai = ai;
                        state = V6C;
                    } else if (specified_family == AF_INET) {
                        selectable_addrinfos.ip4_ai = ai;
                        state = V4C;
                    }
                } else {
                    // getaddrinfoの実行
                    for (int i = 0; i < 2; i++) {
                        allocate_rb_getaddrinfo_happy_entry(&(arg->getaddrinfo_entries[i]), portp, &portp_offset);
                        if (!(arg->getaddrinfo_entries[i])) return EAI_MEMORY;

                        allocate_rb_getaddrinfo_happy_entry_endpoint(
                            &(arg->getaddrinfo_entries[i]->node),
                            hostp,
                            &hostp_offset,
                            (char *)arg->getaddrinfo_entries[i]
                        );
                        allocate_rb_getaddrinfo_happy_entry_endpoint(
                            &(arg->getaddrinfo_entries[i]->service),
                            portp,
                            &portp_offset,
                            (char *)arg->getaddrinfo_entries[i]
                        );
                        allocate_rb_getaddrinfo_happy_entry_hints(
                            &getaddrinfo_hints[i],
                            families[i],
                            remote_addrinfo_hints,
                            additional_flags
                        );

                        arg->getaddrinfo_entries[i]->hints = getaddrinfo_hints[i];
                        arg->getaddrinfo_entries[i]->ai = NULL;
                        arg->getaddrinfo_entries[i]->family = families[i];
                        arg->getaddrinfo_entries[i]->refcount = 2;
                        arg->getaddrinfo_entries[i]->cancelled = &cancelled;
                        arg->getaddrinfo_entries[i]->notifying = hostname_resolution_notifying;
                        arg->getaddrinfo_entries[i]->lock = lock;

                        if (do_pthread_create(&threads[i], do_rb_getaddrinfo_happy, arg->getaddrinfo_entries[i]) != 0) {
                            free_rb_getaddrinfo_happy_entry(arg->getaddrinfo_entries[i]);
                            close_fd(hostname_resolution_waiting);
                            close_fd(hostname_resolution_notifying);
                            return EAI_AGAIN;
                        }
                        pthread_detach(threads[i]);
                    }

                    int hostname_resolution_retry_count = 1;

                    while (hostname_resolution_retry_count >= 0) {
                        // getaddrinfoの待機
                        if (resolv_timeout_tv) {
                            wait_arg.delay = resolv_timeout_tv;
                            hostname_resolution_expires_at_ts = resolv_timeout_expires_at_ts(*resolv_timeout_tv);
                        }

                        FD_ZERO(&readfds);
                        FD_SET(hostname_resolution_waiting, &readfds);
                        nfds = hostname_resolution_waiting + 1;
                        rb_thread_call_without_gvl2(wait_happy_eyeballs_fds, &wait_arg, cancel_happy_eyeballs_fds, &cancel_arg);
                        status = wait_arg.status;
                        syscall = "select(2)";

                        if (status == 0) { // resolv_timeout
                            state = TIMEOUT;
                            continue;
                        } else if (status < 0) { // selectの実行失敗
                            rb_syserr_fail(errno, "select(2)"); // いったんこれで
                        }

                        bytes_read = read(hostname_resolution_waiting, written, sizeof(written) - 1);
                        written[bytes_read] = '\0';

                        if (strcmp(written, IPV6_HOSTNAME_RESOLVED) == 0) {
                            tmp_getaddrinfo_entry = arg->getaddrinfo_entries[0];
                            tmp_need_free = arg->need_frees[0];
                            selectable_addrinfos.ip6_ai = tmp_getaddrinfo_entry->ai;
                        } else if (strcmp(written, IPV4_HOSTNAME_RESOLVED) == 0) {
                            tmp_getaddrinfo_entry = arg->getaddrinfo_entries[1];
                            tmp_need_free = arg->need_frees[1];
                            selectable_addrinfos.ip4_ai = tmp_getaddrinfo_entry->ai;
                        }

                        if (tmp_getaddrinfo_entry->err != 0) {
                            if (tmp_getaddrinfo_entry->err != EAI_ADDRFAMILY) {
                                last_error = tmp_getaddrinfo_entry->err;
                            }

                            rb_nativethread_lock_lock(lock);
                            {
                                if (--tmp_getaddrinfo_entry->refcount == 0) *tmp_need_free = 1;
                            }
                            rb_nativethread_lock_unlock(lock);
                            hostname_resolution_retry_count--;

                            if (hostname_resolution_retry_count == 0) {
                                state = FAILURE;
                                break;
                            }
                        } else {
                            /*
                             * Maybe also accept a local address
                             */

                            // locat_host / local_portが指定された場合
                            if (!NIL_P(inetsock_resource->local.host) || !NIL_P(inetsock_resource->local.serv)) {
                                inetsock_resource->local.res = rsock_addrinfo(
                                    inetsock_resource->local.host,
                                    inetsock_resource->local.serv,
                                    AF_UNSPEC,
                                    SOCK_STREAM,
                                    0
                                );
                            }

                            if (tmp_getaddrinfo_entry->family == AF_INET6) {
                                state = V6C;
                            } else if (tmp_getaddrinfo_entry->family == AF_INET) {
                                if (arg->getaddrinfo_entries[0]->err) { // v6の名前解決に失敗している場合
                                    state = V4C;
                                } else { // v6の名前解決が終わっていない場合
                                    state = V4W;
                                }
                            }
                            break;
                        }
                    }
                }

                continue;
            }

            case V4W:
            {
                resolution_delay.tv_sec = 0;
                resolution_delay.tv_usec = RESOLUTION_DELAY_USEC;
                wait_arg.delay = &resolution_delay;
                FD_ZERO(&readfds);
                FD_SET(hostname_resolution_waiting, &readfds);
                nfds = hostname_resolution_waiting + 1;
                rb_thread_call_without_gvl2(wait_happy_eyeballs_fds, &wait_arg, cancel_happy_eyeballs_fds, &cancel_arg);
                status = wait_arg.status;
                syscall = "select(2)";

                if (status == 0) {
                    state = V4C;
                } else { // 名前解決できた
                    read(hostname_resolution_waiting, written, sizeof(written) - 1);
                    selectable_addrinfos.ip6_ai = arg->getaddrinfo_entries[0]->ai;
                    state = V46C;
                }
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
                    if (is_connecting_fds_empty(arg->connecting_fds, *connecting_fds_size) &&
                        is_hostname_resolution_finished(hostname_resolution_waiting)) {
                        state = FAILURE;
                    } else {
                        if (resolv_timeout_tv &&
                            !is_hostname_resolution_finished(hostname_resolution_waiting) &&
                            is_timeout(hostname_resolution_expires_at_ts)) {
                            state = TIMEOUT;
                        } else {
                            state = V46W;
                        }
                    }
                    continue;
                }

                #if !defined(INET6) && defined(AF_INET6) // TODO 必要?
                if (remote_ai->ai_family == AF_INET6)
                    inetsock_resource->fd = fd = -1;

                    if (!(selectable_addrinfos.ip6_ai || selectable_addrinfos.ip4_ai) &&
                        is_connecting_fds_empty(arg->connecting_fds, *connecting_fds_size) &&
                        is_hostname_resolution_finished(hostname_resolution_waiting)) {
                        state = FAILURE;
                    } else if (selectable_addrinfos.ip6_ai || selectable_addrinfos.ip4_ai) {
                        // Try other addrinfo in next loop
                        last_family = AF_INET6; // TODO これで良い?
                    } else {
                        if (resolv_timeout_tv &&
                            !is_hostname_resolution_finished(hostname_resolution_waiting) &&
                            is_timeout(hostname_resolution_expires_at_ts)) {
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
                            is_connecting_fds_empty(arg->connecting_fds, *connecting_fds_size) &&
                            is_hostname_resolution_finished(hostname_resolution_waiting)) {
                            // 試せるリモートaddrinfoが存在しないことが確定している
                            /* Use a different family local address if no choice, this
                             * will cause EAFNOSUPPORT. */
                            last_error = EAFNOSUPPORT;
                            state = FAILURE;
                        } else if (selectable_addrinfos.ip6_ai || selectable_addrinfos.ip4_ai) {
                            // Try other addrinfo in next loop
                        } else {
                            if (resolv_timeout_tv &&
                                !is_hostname_resolution_finished(hostname_resolution_waiting) &&
                                is_timeout(hostname_resolution_expires_at_ts)) {
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
                        is_connecting_fds_empty(arg->connecting_fds, *connecting_fds_size) &&
                        is_hostname_resolution_finished(hostname_resolution_waiting)) {
                        state = FAILURE;
                    } else if (selectable_addrinfos.ip6_ai || selectable_addrinfos.ip4_ai) {
                        // Try other addrinfo in next loop
                    } else {
                        if (resolv_timeout_tv &&
                            !is_hostname_resolution_finished(hostname_resolution_waiting) &&
                            is_timeout(hostname_resolution_expires_at_ts)) {
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
                    local = status;
                    syscall = "bind(2)";

                    if (status < 0) { // bind(2) に失敗
                        last_error = errno;
                        inetsock_resource->fd = fd = -1;

                        if (!(selectable_addrinfos.ip6_ai || selectable_addrinfos.ip4_ai) &&
                            is_connecting_fds_empty(arg->connecting_fds, *connecting_fds_size) &&
                            is_hostname_resolution_finished(hostname_resolution_waiting)) {
                            state = FAILURE;
                        } else if (selectable_addrinfos.ip6_ai || selectable_addrinfos.ip4_ai) {
                            // Try other addrinfo in next loop
                        } else {
                            if (resolv_timeout_tv &&
                                !is_hostname_resolution_finished(hostname_resolution_waiting) &&
                                is_timeout(hostname_resolution_expires_at_ts)) {
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

                if (status >= 0) {
                    socket_nonblock_set(fd, true);
                    status = connect(fd, remote_ai->ai_addr, remote_ai->ai_addrlen);
                    syscall = "connect(2)";
                }

                last_family = remote_ai->ai_family;

                if (status == 0) { // 接続に成功
                    state = SUCCESS;
                } else if (errno == EINPROGRESS) { // 接続中
                    arg->connecting_fds[(*connecting_fds_size)++] = fd;
                    state = V46W;
                } else { // connect(2)に失敗
                    last_error = errno;
                    close_fd(fd);
                    inetsock_resource->fd = fd = -1;

                    if (!(selectable_addrinfos.ip6_ai || selectable_addrinfos.ip4_ai) &&
                        is_connecting_fds_empty(arg->connecting_fds, *connecting_fds_size) &&
                        is_hostname_resolution_finished(hostname_resolution_waiting)) {
                        state = FAILURE;
                    } else if (selectable_addrinfos.ip6_ai || selectable_addrinfos.ip4_ai) {
                        // Try other addrinfo in next loop
                    } else {
                        if (resolv_timeout_tv &&
                            !is_hostname_resolution_finished(hostname_resolution_waiting) &&
                            is_timeout(hostname_resolution_expires_at_ts)) {
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

                FD_ZERO(&readfds);
                FD_SET(hostname_resolution_waiting, &readfds);

                connection_attempt_delay.tv_sec = 0;
                connection_attempt_delay.tv_usec = (int)usec_to_timeout(connection_attempt_delay_expires_at);
                wait_arg.delay = &connection_attempt_delay;

                nfds = set_connecting_fds(arg->connecting_fds, *connecting_fds_size, &writefds);
                rb_thread_call_without_gvl2(wait_happy_eyeballs_fds, &wait_arg, cancel_happy_eyeballs_fds, &cancel_arg);
                status = wait_arg.status;
                syscall = "select(2)";

                if (status > 0) {
                    if (FD_ISSET(hostname_resolution_waiting, &readfds)) { // 名前解決できた
                        bytes_read = read(hostname_resolution_waiting, written, sizeof(written) - 1);
                        written[bytes_read] = '\0';

                        if (strcmp(written, IPV6_HOSTNAME_RESOLVED) == 0) {
                            selectable_addrinfos.ip6_ai = arg->getaddrinfo_entries[0]->ai;
                            tmp_getaddrinfo_entry = arg->getaddrinfo_entries[0];
                            tmp_need_free = arg->need_frees[0];
                        } else if (strcmp(written, IPV4_HOSTNAME_RESOLVED) == 0) {
                            selectable_addrinfos.ip4_ai = arg->getaddrinfo_entries[1]->ai;
                            tmp_getaddrinfo_entry = arg->getaddrinfo_entries[1];
                            tmp_need_free = arg->need_frees[1];
                        }

                        if (tmp_getaddrinfo_entry->err) {
                            rb_nativethread_lock_lock(lock);
                            {
                                if (--tmp_getaddrinfo_entry->refcount == 0) *tmp_need_free = 1;
                            }
                            rb_nativethread_lock_unlock(lock);
                        }
                    } else { // writefdsに書き込み可能ソケットができた
                        inetsock_resource->fd = fd = find_connected_socket(arg->connecting_fds, *connecting_fds_size, &writefds);
                        if (fd >= 0) {
                            state = SUCCESS;
                        } else {
                            last_error = errno;
                            close_fd(fd);
                            inetsock_resource->fd = fd = -1;

                            if (!(selectable_addrinfos.ip6_ai || selectable_addrinfos.ip4_ai) &&
                                is_connecting_fds_empty(arg->connecting_fds, *connecting_fds_size) &&
                                is_hostname_resolution_finished(hostname_resolution_waiting)) {
                                state = FAILURE;
                            } else if (selectable_addrinfos.ip6_ai || selectable_addrinfos.ip4_ai) {
                                // Wait for connection attempt delay in next loop
                            } else {
                                if (resolv_timeout_tv &&
                                    !is_hostname_resolution_finished(hostname_resolution_waiting) &&
                                    is_timeout(hostname_resolution_expires_at_ts)) {
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
                        is_connecting_fds_empty(arg->connecting_fds, *connecting_fds_size) &&
                        is_hostname_resolution_finished(hostname_resolution_waiting)) {
                        state = FAILURE;
                    } else if (selectable_addrinfos.ip6_ai || selectable_addrinfos.ip4_ai) {
                        // Try other Addrinfo in next loop
                        state = V46C;
                    } else {
                        if (resolv_timeout_tv &&
                            !is_hostname_resolution_finished(hostname_resolution_waiting) &&
                            is_timeout(hostname_resolution_expires_at_ts)) {
                            state = TIMEOUT;
                        } else {
                            // Wait for connection to be established or hostname resolution in next loop
                            connection_attempt_delay_expires_at = (struct timespec){ -1, -1 };
                        }
                    }
                } else { // selectに失敗
                    last_error = errno;
                    close_fd(fd);
                    inetsock_resource->fd = fd = -1;

                    if (!(selectable_addrinfos.ip6_ai || selectable_addrinfos.ip4_ai) &&
                        is_connecting_fds_empty(arg->connecting_fds, *connecting_fds_size) &&
                        is_hostname_resolution_finished(hostname_resolution_waiting)) {
                        state = FAILURE;
                    } else {
                        if (resolv_timeout_tv &&
                            !is_hostname_resolution_finished(hostname_resolution_waiting) &&
                            is_timeout(hostname_resolution_expires_at_ts)) {
                            state = TIMEOUT;
                        } else {
                            // Wait for Connection Attempt Delay or connection to be established or hostname resolution in next loop
                        }
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

                if (local < 0) { // locat_host / local_portが指定されており、ローカルに接続可能なアドレスファミリがなかった場合
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

    *arg->connected_fd = inetsock_resource->fd;
    inetsock_resource->fd = -1;

    /* create new instance */
    return rsock_init_sock(inetsock_resource->sock, fd);
}

static VALUE
inetsock_cleanup_happy(VALUE v)
{
    struct inetsock_happy_arg *arg = (void *)v;
    struct inetsock_arg *inetsock_resource = arg->inetsock_resource;

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

    rb_nativethread_lock_lock(arg->lock);
    {
        for (int i = 0; i < 2; i++) {
            if (arg->getaddrinfo_entries[i] && --(arg->getaddrinfo_entries[i]->refcount) == 0) {
                *(arg->need_frees[i]) = 1;
            }
        }
    }
    rb_nativethread_lock_unlock(arg->lock);

    for (int i = 0; i < 2; i++) {
        if (arg->getaddrinfo_entries[i] && arg->need_frees[i]) {
            free_rb_getaddrinfo_happy_entry(arg->getaddrinfo_entries[i]);
        }
    }

    close_fd(arg->hostname_resolution_waiting);
    close_fd(arg->hostname_resolution_notifying);
    rb_nativethread_lock_destroy(arg->lock);

    for (int i = 0; i < *arg->connecting_fds_size; i++) {
        int connecting_fd = arg->connecting_fds[i];
        if (connecting_fd != *(arg->connected_fd)) close_fd(connecting_fd);
    }

    free(arg->connecting_fds);

    return Qnil;
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
        struct inetsock_happy_arg inetsock_happy_resource;
        memset(&inetsock_happy_resource, 0, sizeof(inetsock_happy_resource));

        inetsock_happy_resource.inetsock_resource = &arg;

        rb_nativethread_lock_t lock;
        rb_nativethread_lock_initialize(&lock);
        inetsock_happy_resource.lock = &lock;

        int hostname_resolution_waiting, hostname_resolution_notifying;
        int pipefd[2];
        pipe(pipefd);
        hostname_resolution_waiting = pipefd[0];
        hostname_resolution_notifying = pipefd[1];
        inetsock_happy_resource.hostname_resolution_waiting = hostname_resolution_waiting;
        inetsock_happy_resource.hostname_resolution_notifying = hostname_resolution_notifying;

        int ipv6_need_free, ipv4_need_free = 0;
        inetsock_happy_resource.need_frees[0] = &ipv6_need_free;
        inetsock_happy_resource.need_frees[1] = &ipv4_need_free;

        int connecting_fds_size = 0;
        int connecting_fds_capacity = 0;
        inetsock_happy_resource.connecting_fds_size = &connecting_fds_size;
        inetsock_happy_resource.connecting_fds_capacity = &connecting_fds_capacity;

        int connected_fd = -1;
        inetsock_happy_resource.connected_fd = &connected_fd;

        return rb_ensure(init_inetsock_internal_happy, (VALUE)&inetsock_happy_resource,
                         inetsock_cleanup_happy, (VALUE)&inetsock_happy_resource);
    } else {
        return rb_ensure(init_inetsock_internal, (VALUE)&arg,
                         inetsock_cleanup, (VALUE)&arg);
    }
}
```
