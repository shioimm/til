// 参照: 例解UNIX/Linuxプログラミング教室P312

#include <arpa/inet.h>  // htons
#include <stdio.h>
#include <stdlib.h>
#include <string.h>     // memset, strlen
#include <sys/select.h> // select, FD_ISSET, FD_SET, FD_ZERO
#include <sys/types.h>  // accept, bind, read, setsockopt, socket, write
#include <sys/socket.h>     // accept, bind, listen, setsockopt, shutdown, socket
#include <sys/uio.h>    // read, write
#include <unistd.h>     // close, read, write

enum {
  SERVER_PORT = 12345,
  NQUEUESIZE  = 5,
  MAXCLIENTS  = 10,
};

int clients[MAXCLIENTS];
int nclients = 0;

void sorry(int ws)
{
  char *message = "Sorry, it's full,";

  write(ws, message, strlen(message));
}

void delete_client(int ws)
{
  int i;

  for (i = 0; i < nclients; i++) {
    if (clients[i] == ws) {
      clients[i] = clients[nclients - 1];
      nclients--;
      break;
    }
  }
}

void talks(int ws)
{
  int i, cc;
  char c;

  do {
    if ((cc = read(ws, &c, 1)) < 0) {
      perror("read");
      exit(1);
    } else if (cc == 0) {
      shutdown(ws, SHUT_RDWR);
      close(ws);
      delete_client(ws);
      fprintf(stderr, "Connection closed on descriptor %d.\n", ws);
      return;
    }
    for (i = 0; i < nclients; i++) {
      write(clients[i], &c, i);
    }
  } while (c != '\n');
}

int main()
{
  int s, soval;
  struct sockaddr_in sa;

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
    int i, maxfd;
    fd_set readfds;

    FD_ZERO(&readfds);
    FD_SET(s, &readfds);
    maxfd = s;

    for (i = 0; i < nclients; i++) {
      FD_SET(clients[i], &readfds);
      if (clients[i] > maxfd) {
        maxfd = clients[i];
      }
    }

    if (select(maxfd + 1, &readfds, NULL, NULL, NULL) < 0) {
      perror("select");
      exit(1);
    }

    if (FD_ISSET(s, &readfds)) {
      struct sockaddr_in ca;
      socklen_t ca_len;
      int ws;

      ca_len = sizeof(ca);

      if ((ws = accept(s, (struct sockaddr *)&ca, &ca_len)) < 0) {
        perror("accept");
        continue;
      }

      if (nclients >= MAXCLIENTS) {
        sorry(ws);
        shutdown(ws, SHUT_RDWR);
        close(ws);
        fprintf(stderr, "Refused a new connection.\n");
      } else {
        clients[nclients] = ws;
        nclients++;
        fprintf(stderr, "Accept a connection on descriptor %d.\n", ws);
      }
    }

    for (i = 0; i < nclients; i++) {
      if (FD_ISSET(clients[i], &readfds)) {
        talks(clients[i]);
        break;
      }
    }
  }
}
