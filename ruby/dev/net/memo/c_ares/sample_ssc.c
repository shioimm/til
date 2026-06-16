#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <poll.h>
#include <ares.h>

typedef struct {
    ares_channel_t *channel;
    struct pollfd *poll_fds;
    size_t poll_nfds;
    size_t poll_fds_alloc;
    ares_fd_events_t *ares_fds;
    size_t ares_nfds;
    int queries_ongoing;
} dns_state_t;

// https://github.com/c-ares/c-ares/blob/main/include/ares.h
// struct ares_options {
//   int            flags;
//   int            timeout; /* in seconds or milliseconds, depending on options */
//   int            tries;
//   int            ndots;
//   unsigned short udp_port; /* host byte order */
//   unsigned short tcp_port; /* host byte order */
//   int            socket_send_buffer_size;
//   int            socket_receive_buffer_size;
//   struct in_addr    *servers;
//   int                nservers;
//   char             **domains;
//   int                ndomains;
//   char              *lookups;
//   ares_sock_state_cb sock_state_cb;
//   void              *sock_state_cb_data;
//   struct apattern   *sortlist;
//   int                nsort;
//   int                ednspsz;
//   char              *resolvconf_path;
//   char              *hosts_path;
//   int                udp_max_queries;
//   int                maxtimeout; /* in milliseconds */
//   unsigned int qcache_max_ttl;   /* Maximum TTL for query cache, 0=disabled */
//   ares_evsys_t evsys;
//   struct ares_server_failover_options server_failover_opts;
// };

static void
sock_state_callback(void *data, ares_socket_t fd, int read_required, int write_required)
{
    dns_state_t *state = data;
    size_t i;  // 監視中のソケットエントリの配列のうち、コールバックで通知されたソケット (fd) の位置

    for (i = 0; i < state->poll_nfds; i++) {
        // コールバックで通知されたソケット (fd) をすでに監視中
        if (state->poll_fds[i].fd == fd) break;
    }

    if (i >= state->poll_nfds) { // 新規のソケット
        if (!read_required && !write_required) return; // 読み取り不要・書き込み不要

        state->poll_nfds++;

        if (state->poll_nfds > state->poll_fds_alloc) {
            state->poll_fds_alloc = state->poll_nfds;
            state->poll_fds = realloc(state->poll_fds, sizeof(*state->poll_fds) * state->poll_nfds);
            state->ares_fds = realloc(state->ares_fds, sizeof(*state->ares_fds) * state->poll_nfds);
        }
    } else { // すでに監視中のソケット
        if (!read_required && !write_required) { // 読み取り不要・書き込み不要
            memmove(
                &state->poll_fds[i],
                &state->poll_fds[i + 1],
                sizeof(*state->poll_fds) * (state->poll_nfds - i - 1)
            );
            state->poll_nfds--;
            return;
        }
    }

    state->poll_fds[i].fd = fd;
    state->poll_fds[i].events = 0;
    if (read_required) state->poll_fds[i].events |= POLLIN;
    if (write_required) state->poll_fds[i].events |= POLLOUT;
}

static void
process(dns_state_t *state)
{
    struct timeval tv;

    while (state->queries_ongoing > 0) {
        int ret;
        int timeout;

        // 次にタイムアウト処理が必要になるまでの残り時間をtvに格納
        // 進行中のクエリがなければbreak
        if (ares_timeout(state->channel, NULL, &tv) == NULL) break;

        timeout = (int)(tv.tv_sec * 1000 + tv.tv_usec / 1000);
        ret = poll(state->poll_fds, (nfds_t)state->poll_nfds, timeout);

        if (ret < 0) continue; // poll(2) エラー

        if (ret == 0) { // poll(2) タイムアウト
            // c-ares側のタイムアウト処理を実行
            ares_process_fd(state->channel, ARES_SOCKET_BAD, ARES_SOCKET_BAD);
            continue;
        }

        state->ares_nfds = 0;

        for (size_t i = 0; i < state->poll_nfds; i++) {
            // イベントが発生しなかったソケットはスキップ
            if (state->poll_fds[i].revents == 0) continue;

            size_t index = state->ares_nfds++;
            state->ares_fds[index].fd = state->poll_fds[i].fd;
            state->ares_fds[index].events = 0;

            // 読み取り可能イベントが発生した
            if (state->poll_fds[i].revents & (POLLERR | POLLHUP | POLLIN)) {
                state->ares_fds[index].events |= ARES_FD_EVENT_READ;
            }
            // 書き込み可能イベントが発生した
            if (state->poll_fds[i].revents & (POLLOUT)) {
                state->ares_fds[index].events |= ARES_FD_EVENT_WRITE;
            }
        }

        // イベントの発生をc-aresに通知
        // c-aresは
        //   - ARES_FD_EVENT_READが立っているソケットに対してrecvを呼び、DNSレスポンスを取得
        //   - ARES_FD_EVENT_WRITEが立っているソケットに対してsendを呼び、DNSクエリを送出
        //   - 受信したレスポンスを解析し、完了したクエリのコールバックを呼ぶ
        //   - タイムアウトしたクエリがあれば再送処理
        ares_process_fds(
            state->channel,
            state->ares_fds,
            state->ares_nfds,
            ARES_PROCESS_FLAG_NONE
        );
    }
}

static void
https_callback(void *data, ares_status_t status, size_t timeouts, const ares_dns_record_t *record)
{
    dns_state_t *state = data;
    (void)timeouts;

    state->queries_ongoing--;
    printf("[HTTPS] %s\n", ares_strerror(status));

    if (status != ARES_SUCCESS || !record) return;

    for (size_t i = 0; i < ares_dns_record_rr_cnt(record, ARES_SECTION_ANSWER); i++) {
        const ares_dns_rr_t *rr = ares_dns_record_rr_get_const(record, ARES_SECTION_ANSWER, i);
        if (ares_dns_rr_get_type(rr) != ARES_REC_TYPE_HTTPS) continue;

        printf(
            "[HTTPS] priority=%u target=\"%s\"\n",
            ares_dns_rr_get_u16(rr, ARES_RR_HTTPS_PRIORITY),
            ares_dns_rr_get_str(rr, ARES_RR_HTTPS_TARGET)
        );

        size_t opt_count = ares_dns_rr_get_opt_cnt(rr, ARES_RR_HTTPS_PARAMS);

        for (size_t opt = 0; opt < opt_count; opt++) {
            const unsigned char *val = NULL;
            size_t len = 0;
            unsigned short key = ares_dns_rr_get_opt(rr, ARES_RR_HTTPS_PARAMS, opt, &val, &len);
            printf("[HTTPS]   param key=%u len=%zu\n", (unsigned)key, len);
        }
    }
}

static void
aaaa_callback(void *data, int status, int timeouts, struct ares_addrinfo *result)
{
    dns_state_t *state = data;
    (void)timeouts;

    state->queries_ongoing--;
    printf("[AAAA] %s\n", ares_strerror(status));

    if (result) {
        struct ares_addrinfo_node *node;

        for (node = result->nodes; node != NULL; node = node->ai_next) {
            if (node->ai_family == AF_INET6) {
                char buf[64] = "";
                const struct sockaddr_in6 *in6 = (const struct sockaddr_in6 *)((void *)node->ai_addr);
                ares_inet_ntop(AF_INET6, &in6->sin6_addr, buf, sizeof(buf));
                printf("[AAAA] %s\n", buf);
            }
        }
        ares_freeaddrinfo(result);
    }
}

static void
a_callback(void *data, int status, int timeouts, struct ares_addrinfo *result)
{
    dns_state_t *state = data;
    (void)timeouts;

    state->queries_ongoing--;
    printf("[A] %s\n", ares_strerror(status));

    if (result) {
        struct ares_addrinfo_node *node;

        for (node = result->nodes; node != NULL; node = node->ai_next) {
            if (node->ai_family == AF_INET) {
                char buf[64] = "";
                const struct sockaddr_in *in = (const struct sockaddr_in *)((void *)node->ai_addr);
                ares_inet_ntop(AF_INET, &in->sin_addr, buf, sizeof(buf));
                printf("[A] %s\n", buf);
            }
        }
        ares_freeaddrinfo(result);
    }
}

int
main(int argc, char **argv)
{
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <hostname>\n", argv[0]);
        return 1;        
    }

    dns_state_t state;
    struct ares_options options;
    int optmask = 0;

    memset(&state, 0, sizeof(state));
    memset(&options, 0, sizeof(options));

    ares_library_init(ARES_LIB_INIT_ALL);

    optmask |= ARES_OPT_SOCK_STATE_CB;
    options.sock_state_cb = sock_state_callback;
    options.sock_state_cb_data = &state;

    if (ares_init_options(&state.channel, &options, optmask) != ARES_SUCCESS) {
        fprintf(stderr, "ares_init_options failed\n");
        return 1;
    }

    {
        struct ares_addrinfo_hints hints;
        memset(&hints, 0, sizeof(hints));
        hints.ai_family = PF_INET6;
        hints.ai_socktype = SOCK_STREAM;
        hints.ai_flags = ARES_AI_NUMERICSERV;
        state.queries_ongoing++;
        ares_getaddrinfo(state.channel, argv[1], "443", &hints, aaaa_callback, &state);
    }

    {
        struct ares_addrinfo_hints hints;
        memset(&hints, 0, sizeof(hints));
        hints.ai_family = PF_INET;
        hints.ai_socktype = SOCK_STREAM;
        hints.ai_flags = ARES_AI_NUMERICSERV;
        state.queries_ongoing++;
        ares_getaddrinfo(state.channel, argv[1], "443", &hints, a_callback, &state);
    }

    {
        state.queries_ongoing++;
        ares_query_dnsrec(
            state.channel,
            argv[1],
            ARES_CLASS_IN, // クラス
            ARES_REC_TYPE_HTTPS, // レコード種別
            https_callback,
            &state,
            NULL
        );
    }

    process(&state);

    ares_destroy(state.channel);
    free(state.poll_fds);
    free(state.ares_fds);
    ares_library_cleanup();

    return 0;
}