#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <poll.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <ares.h>

// [main] c-ares library を初期化
// -> [main] Sock State Callback付きでchannelを作成
// -> [main] ares_getaddrinfo("example.com")
// -> [process_dns_events] poll() でイベントループを回す
// -> [process_dns_events] DNS応答またはtimeoutをc-aresに通知
// -> [addrinfo_callback] 結果を表示
// -> [main] クリーンアップ

typedef struct {
  ares_channel_t *channel;

  struct pollfd *poll_fds; // poll() に渡すfd配列
  size_t poll_nfds;        // 現在監視しているfd数
  size_t poll_fds_alloc;   // poll_fds / ares_fdsに確保済みの要素数

  ares_fd_events_t *ares_fds; // poll() で発生したeventをc-aresに渡すための配列
  size_t ares_nfds;

  int failed;
} dns_state_t;

// data: options.sock_state_cb_dataに渡すchannel
// sock: c-aresが監視するsocket fd
// readable: read監視が必要 = true
// writable: write監視が必要 = true
static void
sock_state_callback(void *data, ares_socket_t sock, int readable, int writable)
{
    dns_state_t *state = data;
    size_t i;

    // sockがすでにpoll_fdsに登録済みなら何もしない
    for (i = 0; i < state->poll_nfds; i++) {
        if (state->poll_fds[i].fd == sock) break;
    }

    if (i == state->poll_nfds) {
        if (!readable && !writable) return;

        if (state->poll_nfds == state->poll_fds_alloc) {
            size_t new_alloc = state->poll_fds_alloc == 0 ? 4  : state->poll_fds_alloc * 2;

            struct pollfd *new_poll_fds = realloc(state->poll_fds, sizeof(*state->poll_fds) * new_alloc);
            if (new_poll_fds == NULL) {
                state->failed = 1;
                return;
            }
            state->poll_fds = new_poll_fds;

            ares_fd_events_t *new_ares_fds = realloc(state->ares_fds, sizeof(*state->ares_fds) * new_alloc);
            if (new_ares_fds == NULL) {
                state->failed = 1;
                return;
            }
            state->ares_fds = new_ares_fds;

            state->poll_fds_alloc = new_alloc;
        }

        state->poll_nfds++;
    } else {
        // 監視が不要なfdをpoll_fdsから削除
        if (!readable && !writable) {
            memmove(
                &state->poll_fds[i],
                &state->poll_fds[i + 1],
                sizeof(*state->poll_fds) * (state->poll_nfds - i -1)
            );
            state->poll_nfds--;
            return;
        }
    }

    // poll() に渡す監視条件を設定
    state->poll_fds[i].fd      = sock;
    state->poll_fds[i].events  = 0;
    state->poll_fds[i].revents = 0;

    if (readable) state->poll_fds[i].events |= POLLIN;
    if (writable) state->poll_fds[i].events |= POLLOUT;
}

static void
addrinfo_callback(void * arg, int status, int timeouts, struct ares_addrinfo *result)
{
    (void)arg;
    printf("Result: %s, timeouts: %d\n", ares_strerror(status), timeouts);

    if (status != ARES_SUCCESS) {
        ares_freeaddrinfo(result);
        return;
    }

    for (struct ares_addrinfo_node *node = result->nodes; node != NULL; node = node->ai_next) {
        char abuf[INET6_ADDRSTRLEN];
        const void *addr = NULL;

        if (node->ai_family == AF_INET) {
            const struct sockaddr_in *sa = (const struct sockaddr_in *)node->ai_addr;
            addr = &sa->sin_addr;
        } else if (node->ai_family == AF_INET6) {
            const struct sockaddr_in6 *sa = (const struct sockaddr_in6 *)node->ai_addr;
            addr = &sa->sin6_addr;
        } else {
            continue;
        }

        if (ares_inet_ntop(node->ai_family, addr, abuf, sizeof(abuf)) != NULL) {
            printf("  - %s\n", abuf);
        }
    }

    ares_freeaddrinfo(result);
}

static void
process_dns_events(dns_state_t *state)
{
    ares_status_t ares_status;

    while (!state->failed) {
        struct timeval tv;
        int timeout_ms;
        int status;

        if (ares_timeout(state->channel, NULL, &tv) == NULL) break;

        timeout_ms = (int)(tv.tv_sec * 1000 + tv.tv_usec / 1000);
        status = poll(state->poll_fds, state->poll_nfds, timeout_ms);

        if (status < 0) continue;

        // fd eventがなくc-ares側のtimeoutだけが発生したケース
        if (status == 0) {
            ares_status =  ares_process_fds(state->channel, NULL, 0, ARES_PROCESS_FLAG_NONE);

            if (ares_status != ARES_SUCCESS) {
                state->failed = 1;
                break;
            }

            continue;
        }

        state->ares_nfds = 0;

        for (size_t i = 0; i < state->poll_nfds; i++) {
            if (state->poll_fds[i].revents == 0) continue;

            size_t idx = state->ares_nfds++;
            state->ares_fds[idx].fd = state->poll_fds[i].fd;
            state->ares_fds[idx].events = 0;

            if (state->poll_fds[i].revents & (POLLIN | POLLERR | POLLHUP)) {
                state->ares_fds[idx].events |= ARES_FD_EVENT_READ;
            }
            if (state->poll_fds[i].revents & POLLOUT) {
                state->ares_fds[idx].events |= ARES_FD_EVENT_WRITE;
            }
        }

        // poll() で検出したread/write eventをc-aresへ通知
        ares_status = ares_process_fds(state->channel, state->ares_fds, state->ares_nfds, ARES_PROCESS_FLAG_NONE);
        if (ares_status != ARES_SUCCESS) state->failed = 1;
    }
}

int
main(void)
{
    const char *hostname = "example.com";

    dns_state_t state;
    memset(&state, 0, sizeof(state));

    int status = ares_library_init(ARES_LIB_INIT_ALL);
    if (status != ARES_SUCCESS) {
        fprintf(stderr, "ares_library_init failed: %s\n", ares_strerror(status));
        return 1;
    }

    struct ares_options options;
    memset(&options, 0, sizeof(options));
    options.sock_state_cb = sock_state_callback;
    options.sock_state_cb_data = &state;

    int optmask = 0;
    optmask |= ARES_OPT_SOCK_STATE_CB;

    status = ares_init_options(&state.channel, &options, optmask);

    if (status != ARES_SUCCESS) {
        fprintf(stderr, "ares_init_options failed: %s\n", ares_strerror(status));
        ares_library_cleanup();
        return 1;
    }

    struct ares_addrinfo_hints hints;
    memset(&hints, 0, sizeof(hints));
    hints.ai_family   = AF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;
    hints.ai_protocol = 0;
    hints.ai_flags    = ARES_AI_CANONNAME;

    ares_getaddrinfo(state.channel, hostname, NULL, &hints, addrinfo_callback, NULL);
    process_dns_events(&state);

    if (state.failed) fprintf(stderr, "event loop failed\n");

    ares_destroy(state.channel);
    free(state.poll_fds);
    free(state.ares_fds);
    ares_library_cleanup();

    return state.failed ? 1 : 0;
}
