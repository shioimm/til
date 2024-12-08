#include <stdio.h>
#include <poll.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#define INITIAL_MAX_FDS 10
#define INCREMENT_FDS 10

typedef struct {
    int *fds;
    int count;
    int capacity;
} write_fds;

int main() {
    write_fds wfds;
    wfds.fds = malloc(sizeof(int) * INITIAL_MAX_FDS);
    wfds.count = 0;
    wfds.capacity = INITIAL_MAX_FDS;

    int poll_size = 0;
    int poll_capacity = INITIAL_MAX_FDS;
    struct pollfd *poll_fds = NULL;

    poll_fds = malloc(sizeof(struct pollfd) * poll_capacity);

    if (!poll_fds) {
        perror("malloc");
        return 1;
    }

    int rfd = 0; // stdin
    poll_fds[poll_size].fd = rfd;
    poll_fds[poll_size].events = POLLIN;
    poll_size++;

    printf("Starting poll loop. Type something to trigger stdin.\n");

    while (1) {
        // fdの増減操作
        char command[100];
        printf("Enter command (add/remove/exit): ");
        if (fgets(command, sizeof(command), stdin) == NULL) break;

        if (strncmp(command, "add", 3) == 0) {
            int fd = open("/dev/null", O_WRONLY);

            if (fd == -1) {
                perror("open");
            } else {
                if (wfds.count >= wfds.capacity) {
                    wfds.capacity += INCREMENT_FDS;
                    wfds.fds = realloc(wfds.fds, sizeof(int) * wfds.capacity);
                    if (!wfds.fds) {
                        perror("realloc");
                        exit(1);
                    }
                }
                wfds.fds[wfds.count++] = fd;
                printf("Added write fd: %d\n", fd);
            }
        } else if (strncmp(command, "remove", 6) == 0 && wfds.count > 0) {
            int fd = wfds.fds[wfds.count - 1];

            for (int i = 0; i < wfds.count; i++) {
              if (wfds.fds[i] == fd) {
                close(wfds.fds[i]);
                wfds.fds[i] = wfds.fds[wfds.count - 1];
                wfds.count--;
                printf("Removed write fd: %d\n", fd);
              }
            }
        } else if (strncmp(command, "exit", 4) == 0) {
            printf("Exit\n");
            break;
        }

        poll_size = 1;  // rfdの数
        for (int i = 0; i < wfds.count; i++) {
            if (poll_size >= poll_capacity) {
                poll_capacity += INCREMENT_FDS;
                poll_fds = realloc(poll_fds, sizeof(struct pollfd) * poll_capacity);

                if (!poll_fds) {
                    perror("realloc");
                    exit(1);
                }
            }
            poll_fds[poll_size].fd = wfds.fds[i];
            poll_fds[poll_size].events = POLLOUT;
            poll_size++;
        }

        puts("Start to poll");
        int ret = poll(poll_fds, poll_size, 5000);

        printf("poll_size %d\n", poll_size);

        if (ret == -1) {
            perror("poll");
            break;
        } else if (ret == 0) {
            printf("Timeout\n");
        } else {
            for (int i = 0; i < poll_size; i++) {
                printf("Check for %d\n", poll_fds[i].fd);
                if (poll_fds[i].revents & POLLIN) {
                    printf("Ready to read on fd %d (stdin).\n", poll_fds[i].fd);
                }

                if (poll_fds[i].revents & POLLOUT) {
                    printf("Ready to write on fd %d\n", poll_fds[i].fd);
                    write(poll_fds[i].fd, "test\n", 5);
                }
            }
        }
    }

    for (int i = 0; i < wfds.count; i++) {
        close(wfds.fds[i]);
    }
    free(wfds.fds);
    free(poll_fds);

    return 0;
}
