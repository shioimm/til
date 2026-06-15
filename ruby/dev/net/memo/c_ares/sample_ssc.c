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
} dnsstate_t;

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
sock_state_cb(void *data, ares_socket_t fd, int read_required, int write_required)
{
    dns_state_t state *state = data;
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

int
main(int argc, char **argv)
{
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <hostname>\n", argv[0]);
        return 1;        
    }

    dnsstate_t state;
    strutct ares_options options;
    int optmask = 0;

    memset(&state, 0, sizeof(state));
    memset(&options, 0, sizeof(options)); 

    ares_library_init(ARES_LIB_INIT_ALL);

    optmask |= ARS_OPT_SOCK_STATE_CB;
    options.sock_state_cb = sock_state_cb;
    options.sock_state_cb_data = &state;

    // WIP

    return 0;
}