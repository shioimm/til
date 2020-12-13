#include <stdio.h>      // fgets / fprintf / perror / clearerr
#include <stdlib.h>     // exit
#include <string.h>     // memset / memmove / strlen
#include <unistd.h>     // write / close
#include <sys/socket.h> // ソケット
#include <netdb.h>      // getaddrinfo
#include <sys/types.h>  // getaddrinfo

#define SERVER_NAME "localhost"
#define SERVER_PORT 12345
#define NQUEUESIZE  5

int main ()
{
  // アドレス設定
  struct addrinfo hints, *res;
  int addrinfoerr;

  memset(&hints, 0, sizeof(struct addrinfo));
  hints.ai_family = AF_INET;
  hints.ai_socktype = SOCK_STREAM;
  hints.ai_flags = AI_PASSIVE;

  if ((addrinfoerr = getaddrinfo(NULL, "12345", &hints, &res)) < 0) {
    gai_strerror(addrinfoerr);
  }

  // listen(2)
  int listener;

  if ((listener = socket(res->ai_family, res->ai_socktype, res->ai_protocol)) < 0) {
    perror("socket(2)");
    exit(1);
  }

  // アドレス再利用設定
  int reuse = 1;

  if (setsockopt(listener, SOL_SOCKET, SO_REUSEADDR, &reuse, sizeof(reuse)) < 0) {
    perror("setsockopt(2)");
    exit(1);
  }

  // bind(2)
  if (bind(listener, res->ai_addr, res->ai_addrlen) < 0) {
    perror("bind(2)");
    exit(1);
  }

  freeaddrinfo(res);

  // listen(2)
  if (listen(listener, NQUEUESIZE)) {
    perror("listen(2)");
    exit(1);
  }

  for (;;) {
    // accept(2)
    int                conn;
    struct sockaddr_storage caddr;
    socklen_t                caddr_len = sizeof(caddr);

    if ((conn = accept(listener, (struct sockaddr *)&caddr, &caddr_len)) < 0) {
      perror("accept(2)");
      exit(1);
    }

    // read(2) / write(2)
    char msg[1024];
    int  readmsgsize;
    int  fullmsgsize   = sizeof(msg);
    char receivedmsg[] = "Request has been accepted:\n\n";

    for (;;) {
      readmsgsize = read(conn, msg, fullmsgsize);

      if (readmsgsize == 0) {
        break;
      } else if (readmsgsize < 0) {
        perror("read(2)");
        exit(1);
      }

      write(conn, receivedmsg, sizeof(receivedmsg));
      write(conn, msg, strlen(msg));
      write(conn, "\n", 1);

      if (readmsgsize <= fullmsgsize) {
        break;
      }
    }

    // shutdown(2)
    if (shutdown(conn, SHUT_RDWR) < 0) {
      perror("shutdown(2)");
      exit(1);
    }

    // close(2)
    if (close(conn) < 0) {
      perror("close(2)");
      exit(1);
    }
  }

  return 0;
}
