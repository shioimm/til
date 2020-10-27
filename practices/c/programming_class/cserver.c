// 参照: 例解UNIX/Linuxプログラミング教室P308

#include <sys/types.h>  // socket, bind, accept, setsockopt, write, fork, waitpid
#include <sys/socket.h> // socket, bind, accept, listen, setsockopt, shutdown
#include <stdio.h>
#include <stdlib.h>
#include <string.h>     // memset, strlen
#include <arpa/inet.h>  // htons
#include <sys/uio.h>    // write
#include <unistd.h>     // close, fork, write

#define SERVER_ADDR "127.0.0.1"
#define SERVER_PORT 12345

enum {
  NQUEUESIZE = 5,
};

char *message = "Hello!\nGoodbye!!\n";

int main()
{
  int                s, ws, soval, cc;
  struct sockaddr_in sa, ca;
  socklen_t          ca_len;

  if ((s = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
    perror("socket");
    exit(1);
  }

  soval = 1;

  if (setsockopt(s, SOL_SOCKET, SO_REUSEADDR, &soval, sizeof(soval)) < 0) {
    perror("setsockopt");
    exit(1);
  }

  memset(&sa, 0, sizeof(sa));
  sa.sin_family      = AF_INET;
  sa.sin_port        = htons(SERVER_PORT);
  sa.sin_addr.s_addr = htonl(INADDR_ANY);

  if (bind(s, (struct sockaddr *)&sa, sizeof(sa)) < 0) {
    perror("bind");
    exit(1);
  }

  if (listen(s, NQUEUESIZE) < 0) {
    perror("listen");
    exit(1);
  }

  fprintf(stderr, "Ready.\n");

  for (;;) {
    pid_t forkcc;
    int   status;

    while (waitpid(-1, &status, WNOHANG) > 0);

    fprintf(stderr, "Waiting for a connection...\n");
    ca_len = sizeof(ca);

    if ((ws = accept(s, (struct sockaddr *)&ca, &ca_len)) < 0) {
      perror("accept");
      exit(1);
    }

    fprintf(stderr, "Connection established,\n");

    if ((forkcc = fork()) < 0) {
      perror("fork");
      exit(1);
    } else if (forkcc == 0) {
      if (close(s) < 0) {
        perror("child: close listening socket");
        exit(1);
      }

      fprintf(stderr, "Sending the message...\n");

      if ((cc = write(ws, message, strlen(message))) < 0) {
        perror("write");
        exit(1);
      }

      fprintf(stderr, "Messsage sent.\n");

      if (shutdown(ws, SHUT_RDWR) < 0) {
        perror("shutdown");
        exit(1);
      }

      if (close(ws) < 0) {
        perror("close");
        exit(1);
      }

      exit(0);
    }

    if (close(ws) < 0) {
      perror("close");
      exit(1);
    }
  }
}
