# 2024/2/15
- (参照先: `getaddrinfo/_impl09`)

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

static void
allocate_rb_getaddrinfo_happy_entry_buffer(char **buf, const char *portp, size_t *portp_offset)
{
    size_t getaddrinfo_entry_bufsize = *portp_offset + (portp ? strlen(portp) + 1 : 0);
    char *getaddrinfo_entry_buf = malloc(getaddrinfo_entry_bufsize);

    if (!getaddrinfo_entry_buf) {
        rb_gc();
        getaddrinfo_entry_buf = malloc(getaddrinfo_entry_bufsize);
    }

    *buf = getaddrinfo_entry_buf;
}

static void
allocate_rb_getaddrinfo_happy_entry_endpoint(char **endpoint, const char *source, size_t *offset, char *buf) {
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

// TODO 02-a
// 解決できてないアドレスファミリがある場合に待ち続けるのか、
// 今pipeにあるリソースだけで判断するのかによってロジックが変わってくる (関数名も?)
// ので要検討。
static int
is_hostname_resolution_waiting() // TODO 02-a 引数
{
    if (TRUE) return FALSE; // TODO 02-a pipeが閉じていたらfalse
    // TODO 02-a 以下は今pipeにあるリソースだけで判断する場合のロジック
    // hostname_resolution_waitingを0秒でselectし、FD_ISSETで読み込み可能かを調べる。
    // 可能ならreadせずにtrueを返す
    return FALSE;
}

static VALUE
init_inetsock_internal_happy(VALUE v)
{
    struct inetsock_arg *arg = (void *)v;
    int last_error = 0;
    struct addrinfo *remote_ai = NULL;
    struct addrinfo *local_ai;
    int fd, status = 0, local = 0;
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

    // do_rb_getaddrinfo_happyに渡す引数の準備
    char *hostp, *portp;
    char hbuf[NI_MAXHOST], pbuf[NI_MAXSERV];
    int additional_flags = 0;
    hostp = host_str(arg->remote.host, hbuf, sizeof(hbuf), &additional_flags);
    portp = port_str(arg->remote.serv, pbuf, sizeof(pbuf), &additional_flags);
    size_t hostp_offset = sizeof(struct rb_getaddrinfo_happy_entry);
    size_t portp_offset = hostp_offset + (hostp ? strlen(hostp) + 1 : 0);

    int pipefd[2];
    pipe(pipefd);
    int hostname_resolution_waiting = pipefd[0];
    int hostname_resolution_notifying = pipefd[1];
    rb_nativethread_lock_t lock;
    rb_nativethread_lock_initialize(&lock);
    int cancelled = 0;

    int families[2] = { AF_INET6, AF_INET }; // TODO 要IPアドレス指定対応 / シングルスタック対応

    int tmp_need_free = 0;
    int need_frees[2];
    struct rb_getaddrinfo_happy_entry *ipv6_getaddrinfo_entry = NULL;
    struct rb_getaddrinfo_happy_entry *ipv4_getaddrinfo_entry = NULL;
    struct rb_getaddrinfo_happy_entry *tmp_getaddrinfo_entry = NULL;
    struct rb_getaddrinfo_happy_entry *getaddrinfo_entries[2] = { ipv6_getaddrinfo_entry, ipv4_getaddrinfo_entry };
    struct addrinfo getaddrinfo_hints[2];
    char *getaddrinfo_entry_bufs[2];

    pthread_t threads[2];
    char written[2];
    ssize_t bytes_read;

    int *connecting_fds;
    int connecting_fds_size = 0;
    int capa = 10;
    connecting_fds = malloc(capa * sizeof(int));  // TODO 動的に増やすための関数を用意する
    if (!connecting_fds) {
        perror("Failed to allocate memory");
        return -1;
    }
    fd_set readfds, writefds;
    int nfds;
    struct timeval resolution_delay;
    struct timeval connection_attempt_delay;
    struct timespec connection_attempt_delay_expires_at;

    struct wait_happy_eyeballs_fds_arg wait_arg;
    wait_arg.readfds = &readfds;
    wait_arg.writefds = &writefds;
    wait_arg.nfds = &nfds;
    wait_arg.delay = NULL;

    struct cancel_happy_eyeballs_fds_arg cancel_arg;
    cancel_arg.cancelled = &cancelled;
    cancel_arg.lock = &lock;
    cancel_arg.connecting_fds = connecting_fds;

    int last_family = 0;
    struct resolved_addrinfos selectable_addrinfos = { NULL, NULL };
    struct addrinfo *tmp_selected_ai;

    int stop = 0;
    int state = START;

    while (!stop) {
        printf("\nstate %d\n", state);
        switch (state) {
        {
            case START:
                // getaddrinfoの実行
                for (int i = 0; i < 2; i++) {
                    allocate_rb_getaddrinfo_happy_entry_buffer(&getaddrinfo_entry_bufs[i], portp, &portp_offset);

                    getaddrinfo_entries[i] = (struct rb_getaddrinfo_happy_entry *)getaddrinfo_entry_bufs[i];
                    if (!getaddrinfo_entries[i]) return EAI_MEMORY;

                    allocate_rb_getaddrinfo_happy_entry_endpoint(&getaddrinfo_entries[i]->node, hostp, &hostp_offset, getaddrinfo_entry_bufs[i]);
                    allocate_rb_getaddrinfo_happy_entry_endpoint(&getaddrinfo_entries[i]->service, portp, &portp_offset, getaddrinfo_entry_bufs[i]);
                    allocate_rb_getaddrinfo_happy_entry_hints(&getaddrinfo_hints[i], families[i], remote_addrinfo_hints, additional_flags);

                    getaddrinfo_entries[i]->hints = getaddrinfo_hints[i];
                    getaddrinfo_entries[i]->ai = NULL;
                    getaddrinfo_entries[i]->family = families[i];
                    getaddrinfo_entries[i]->refcount = 2;
                    getaddrinfo_entries[i]->cancelled = &cancelled;
                    getaddrinfo_entries[i]->notifying = hostname_resolution_notifying;
                    getaddrinfo_entries[i]->lock = lock;

                    if (do_pthread_create(&threads[i], do_rb_getaddrinfo_happy, getaddrinfo_entries[i]) != 0) {
                        free_rb_getaddrinfo_happy_entry(getaddrinfo_entries[i]);
                        close_fd(hostname_resolution_waiting);
                        close_fd(hostname_resolution_notifying);
                        return EAI_AGAIN;
                    }
                    pthread_detach(threads[i]);
                }

                // TODO 03 hostname_resolution_retry_count
                // getaddrinfoの待機
                FD_ZERO(&readfds);
                FD_SET(hostname_resolution_waiting, &readfds);
                nfds = hostname_resolution_waiting + 1;
                rb_thread_call_without_gvl2(wait_happy_eyeballs_fds, &wait_arg, cancel_happy_eyeballs_fds, &cancel_arg);
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

                bytes_read = read(hostname_resolution_waiting, written, sizeof(written) - 1);
                written[bytes_read] = '\0';

                if (strcmp(written, IPV6_HOSTNAME_RESOLVED) == 0) {
                    tmp_getaddrinfo_entry = getaddrinfo_entries[0];
                    tmp_need_free = need_frees[0];
                    selectable_addrinfos.ip6_ai = tmp_getaddrinfo_entry->ai;
                } else if (strcmp(written, IPV4_HOSTNAME_RESOLVED) == 0) {
                    tmp_getaddrinfo_entry = getaddrinfo_entries[1];
                    tmp_need_free = need_frees[1];
                    selectable_addrinfos.ip4_ai = tmp_getaddrinfo_entry->ai;
                }

                last_error = tmp_getaddrinfo_entry->err;
                if (last_error != 0) {
                    rb_nativethread_lock_lock(&lock);
                    {
                      if (--tmp_getaddrinfo_entry->refcount == 0) tmp_need_free = 1;
                    }
                    rb_nativethread_lock_unlock(&lock);

                    if (tmp_need_free) free_rb_getaddrinfo_happy_entry(tmp_getaddrinfo_entry);
                    close_fd(hostname_resolution_waiting);
                    close_fd(hostname_resolution_notifying);
                    rsock_raise_resolution_error("init_inetsock_internal_happy", last_error);
                }

                // 不要かも?
                // struct rb_addrinfo *getaddrinfo_res = NULL;
                // getaddrinfo_res = (struct rb_addrinfo *)xmalloc(sizeof(struct rb_addrinfo));
                // getaddrinfo_res->allocated_by_malloc = 0;
                // getaddrinfo_res->ai = tmp_getaddrinfo_entry->ai;

                // arg->remote.res = getaddrinfo_res;
                // arg->fd = fd = -1; // 初期化?
                // remote_ai = arg->remote.res->ai;

                /*
                 * Maybe also accept a local address
                 */

                if (!NIL_P(arg->local.host) || !NIL_P(arg->local.serv)) {
                    arg->local.res = rsock_addrinfo(arg->local.host, arg->local.serv,
                                                    AF_UNSPEC, SOCK_STREAM, 0);
                }

                if (tmp_getaddrinfo_entry->family == AF_INET6) {
                    state = V6C;
                } else if (tmp_getaddrinfo_entry->family == AF_INET) {
                    state = V4W; // TODO 03 v6の名前解決に失敗している場合はv4c
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
                    selectable_addrinfos.ip6_ai = getaddrinfo_entries[0]->ai;
                    state = V46C;
                }
                continue;
            }

            case V6C:
            case V4C:
            case V46C:
            {
                tmp_selected_ai = select_addrinfo(&selectable_addrinfos, last_family);

                if (tmp_selected_ai) {
                    arg->fd = fd = -1;
                    remote_ai = tmp_selected_ai;
                } else { // 接続可能なaddrinfoが見つからなかった
                    if (is_connecting_fds_empty(connecting_fds, connecting_fds_size) &&
                        !is_hostname_resolution_waiting()) { // TODO 02-a
                        state = FAILURE;
                    } else {
                        state = V46W;
                    }
                    continue;
                }

                #if !defined(INET6) && defined(AF_INET6) // TODO 必要?
                if (remote_ai->ai_family == AF_INET6)
                    arg->fd = fd = -1; // これはなに

                    if (is_connecting_fds_empty(connecting_fds, connecting_fds_size) &&
                        (!selectable_addrinfos.ip6_ai && !selectable_addrinfos.ip4_ai) &&
                        !is_hostname_resolution_waiting()) { // TODO 02-a
                            state = FAILURE;
                    } else if (selectable_addrinfos.ip6_ai || selectable_addrinfos.ip4_ai) {
                        // Try other addrinfo in next loop
                        last_family = AF_INET6; // TODO これで良い?
                    } else {
                        // Wait for connection to be established or hostname resolution in next loop
                        connection_attempt_delay_expires_at = (struct timespec){ -1, -1 };
                        state = V46W;
                    }
                    continue;
                #endif

                local_ai = NULL;

                if (arg->local.res) { // locat_host / local_portが指定された場合
                    for (local_ai = arg->local.res->ai; local_ai; local_ai = local_ai->ai_next) {
                        if (local_ai->ai_family == remote_ai->ai_family)
                            break;
                    }
                    if (!local_ai) { // TODO 04 PATIENTLY_RESOLUTION_DELAY?
                        if (is_connecting_fds_empty(connecting_fds, connecting_fds_size) &&
                            (!selectable_addrinfos.ip6_ai && !selectable_addrinfos.ip4_ai) &&
                            !is_hostname_resolution_waiting()) { // TODO 02-a
                            // 試せるリモートaddrinfoが存在しないことが確定している
                            /* Use a different family local address if no choice, this
                             * will cause EAFNOSUPPORT. */
                            state = FAILURE; // TODO 05 EAFNOSUPPORT
                        } else if (selectable_addrinfos.ip6_ai || selectable_addrinfos.ip4_ai) {
                            // Try other addrinfo in next loop
                        } else {
                            // Wait for connection to be established or hostname resolution in next loop
                            connection_attempt_delay_expires_at = (struct timespec){ -1, -1 };
                            state = V46W;
                        }
                        continue;
                    }
                }

                status = rsock_socket(remote_ai->ai_family, remote_ai->ai_socktype, remote_ai->ai_protocol);
                syscall = "socket(2)";
                fd = status;

                if (fd < 0) { // socket(2)に失敗
                    last_error = errno;
                    arg->fd = fd = -1; // これはなに

                    if (is_connecting_fds_empty(connecting_fds, connecting_fds_size) &&
                        (!selectable_addrinfos.ip6_ai && !selectable_addrinfos.ip4_ai) &&
                        !is_hostname_resolution_waiting()) { // TODO 02-a
                            state = FAILURE;
                    } else if (selectable_addrinfos.ip6_ai || selectable_addrinfos.ip4_ai) {
                        // Try other addrinfo in next loop
                    } else {
                        // Wait for connection to be established or hostname resolution in next loop
                        connection_attempt_delay_expires_at = (struct timespec){ -1, -1 };
                        state = V46W;
                    }
                    continue;
                }

                arg->fd = fd;

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
                        arg->fd = fd = -1; // これはなに

                        if (is_connecting_fds_empty(connecting_fds, connecting_fds_size) &&
                            (!selectable_addrinfos.ip6_ai && !selectable_addrinfos.ip4_ai) &&
                            !is_hostname_resolution_waiting()) { // TODO 02-a
                                state = FAILURE;
                        } else if (selectable_addrinfos.ip6_ai || selectable_addrinfos.ip4_ai) {
                            // Try other addrinfo in next loop
                        } else {
                            // Wait for connection to be established or hostname resolution in next loop
                            connection_attempt_delay_expires_at = (struct timespec){ -1, -1 };
                            state = V46W;
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
                    connecting_fds[connecting_fds_size++] = fd;
                    state = V46W;
                } else { // connect(2)に失敗 // TODO 04 PATIENTLY_RESOLUTION_DELAY?
                    last_error = errno;
                    close_fd(fd);
                    arg->fd = fd = -1;

                    if (is_connecting_fds_empty(connecting_fds, connecting_fds_size) &&
                        (!selectable_addrinfos.ip6_ai && !selectable_addrinfos.ip4_ai) &&
                        !is_hostname_resolution_waiting()) { // TODO 02-a
                            state = FAILURE;
                    } else if (selectable_addrinfos.ip6_ai || selectable_addrinfos.ip4_ai) {
                        // Try other addrinfo in next loop
                    } else {
                        // Wait for connection to be established or hostname resolution in next loop
                        connection_attempt_delay_expires_at = (struct timespec){ -1, -1 };
                        state = V46W;
                    }
                }
                continue;
            }

            case V46W:
            {
                FD_ZERO(&readfds);
                FD_SET(hostname_resolution_waiting, &readfds);

                connection_attempt_delay.tv_sec = 0;
                connection_attempt_delay.tv_usec = (int)usec_to_timeout(connection_attempt_delay_expires_at);
                wait_arg.delay = &connection_attempt_delay;

                nfds = set_connecting_fds(connecting_fds, connecting_fds_size, &writefds);
                rb_thread_call_without_gvl2(wait_happy_eyeballs_fds, &wait_arg, cancel_happy_eyeballs_fds, &cancel_arg);
                status = wait_arg.status;
                syscall = "select(2)";

                if (status >= 0) {
                    if (FD_ISSET(hostname_resolution_waiting, &readfds)) { // 名前解決できた
                        bytes_read = read(hostname_resolution_waiting, written, sizeof(written) - 1);
                        written[bytes_read] = '\0';

                        if (strcmp(written, IPV6_HOSTNAME_RESOLVED) == 0) {
                            selectable_addrinfos.ip6_ai = getaddrinfo_entries[0]->ai;
                        } else if (strcmp(written, IPV4_HOSTNAME_RESOLVED) == 0) {
                            selectable_addrinfos.ip4_ai = getaddrinfo_entries[1]->ai;
                        }

                        state = V46W;
                    } else { // writefdsに書き込み可能ソケットができた
                        arg->fd = fd = find_connected_socket(connecting_fds, connecting_fds_size, &writefds);
                        if (fd >= 0) {
                            state = SUCCESS;
                        } else { // TODO 04 PATIENTLY_RESOLUTION_DELAY?
                            last_error = errno;
                            close_fd(fd);
                            arg->fd = fd = -1;

                            if (is_connecting_fds_empty(connecting_fds, connecting_fds_size) &&
                                (!selectable_addrinfos.ip6_ai && !selectable_addrinfos.ip4_ai) &&
                                !is_hostname_resolution_waiting()) { // TODO 02-a
                                    state = FAILURE;
                            } else if (selectable_addrinfos.ip6_ai || selectable_addrinfos.ip4_ai) {
                                // Wait for connection attempt delay in next loop
                            } else {
                                // Wait for connection to be established or hostname resolution in next loop
                                connection_attempt_delay_expires_at = (struct timespec){ -1, -1 };
                            }
                        }
                    }
                } else if (status == 0) {
                    if (is_connecting_fds_empty(connecting_fds, connecting_fds_size) &&
                        (!selectable_addrinfos.ip6_ai && !selectable_addrinfos.ip4_ai) &&
                        !is_hostname_resolution_waiting()) { // TODO 02-a
                        state = FAILURE;
                    } else if (selectable_addrinfos.ip6_ai || selectable_addrinfos.ip4_ai) {
                        // Try other Addrinfo in next loop
                        state = V46C;
                    } else {
                        // Wait for connection to be established or hostname resolution in next loop
                        connection_attempt_delay_expires_at = (struct timespec){ -1, -1 };
                    }
                } else { // selectに失敗
                    last_error = errno;
                    close_fd(fd);
                    arg->fd = fd = -1;

                    if (is_connecting_fds_empty(connecting_fds, connecting_fds_size) &&
                        (!selectable_addrinfos.ip6_ai && !selectable_addrinfos.ip4_ai) &&
                        !is_hostname_resolution_waiting()) { // TODO 02-a
                        state = FAILURE;
                    } else if (selectable_addrinfos.ip6_ai || selectable_addrinfos.ip4_ai) {
                        // Wait for Connection Attempt Delay and try other addrinfo in next loop
                    } else {
                        // Wait for connection to be established or hostname resolution in next loop
                        state = V46W;
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
        for (int i = 0; i < 2; i++) {
            if (--getaddrinfo_entries[i]->refcount == 0) need_frees[i] = 1;
        }
    }
    rb_nativethread_lock_unlock(&lock);

    for (int i = 0; i < 2; i++) {
        if (need_frees[i]) free_rb_getaddrinfo_happy_entry(getaddrinfo_entries[i]);
    }
    close_fd(hostname_resolution_waiting);
    close_fd(hostname_resolution_notifying);

    for (int i = 0; i < connecting_fds_size; i++) {
        int connecting_fd = connecting_fds[i];
        if (connecting_fd != fd) close_fd(connecting_fd);
    }
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
#define IPV6_HOSTNAME_RESOLVED "1"
#define IPV4_HOSTNAME_RESOLVED "2"

char *host_str(VALUE host, char *hbuf, size_t hbuflen, int *flags_ptr);
char *port_str(VALUE port, char *pbuf, size_t pbuflen, int *flags_ptr);

struct rb_getaddrinfo_happy_entry
{
    char *node, *service;
    int family, err, refcount, notifying;
    int *cancelled;
    rb_nativethread_lock_t lock;
    struct addrinfo hints;
    struct addrinfo *ai;
};

int do_pthread_create(pthread_t *th, void *(*start_routine) (void *), void *arg);
void * do_rb_getaddrinfo_happy(void *ptr);
void free_rb_getaddrinfo_happy_entry(struct rb_getaddrinfo_happy_entry *entry);
// -------------------------
```
