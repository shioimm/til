#include <stdio.h>      // fgets / fprintf / perror / clearerr
#include <stdlib.h>     // exit
#include <string.h>     // memset / memmove / strlen
#include <unistd.h>     // write / close
#include <sys/socket.h> // socket / setsockopt / bind
#include <netdb.h>      // struct sockaddr_in / INADDR_ANY

#define SERVER_NAME "localhost"
#define SERVER_PORT 12345
#define NQUEUESIZE  5

int main ()
{
  // listen(2)
  int listener;

  if ((listener = socket(PF_INET, SOCK_STREAM, 0)) < 0) {
    perror("socket(2)");
    exit(1);
  }

  // アドレス再利用設定
  int reuse = 1;

  if (setsockopt(listener, SOL_SOCKET, SO_REUSEADDR, &reuse, sizeof(reuse)) < 0) {
    perror("setsockopt(2)");
    exit(1);
  }

  // アドレス設定
  struct sockaddr_in saddr;

  memset(&saddr, 0, sizeof(saddr));
  saddr.sin_family = PF_INET;
  saddr.sin_port   = htons(SERVER_PORT);
  saddr.sin_addr.s_addr = htonl(INADDR_ANY);

  // bind(2)
  if (bind(listener, (struct sockaddr *)&saddr, sizeof(saddr)) < 0) {
    perror("bind(2)");
    exit(1);
  }

  // listen(2)
  if (listen(listener, NQUEUESIZE)) {
    perror("listen(2)");
    exit(1);
  }

  for (;;) {
    // accept(2)
    int                conn;
    struct sockaddr_in caddr;
    socklen_t          caddr_len = sizeof(caddr);

    if ((conn = accept(listener, (struct sockaddr *)&caddr, &caddr_len)) < 0) {
      perror("accept(2)");
      exit(1);
    }

    // read(2) / write(2)
    char msg[1024];
    int  readmsgsize;
    int  fullmsgsize = sizeof(msg);

    for (;;) {
      readmsgsize = read(conn, msg, fullmsgsize);

      if (readmsgsize == 0) {
        break;
      } else if (readmsgsize < 0) {
        perror("read(2)");
        exit(1);
      }

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
