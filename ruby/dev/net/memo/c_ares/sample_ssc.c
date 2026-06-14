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

int
main(int argc, char **argv)
{
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <hostname>\n", argv[0]);
        return 1;        
    }

    dnsstate_t state;
    // WIP

    return 0;
}