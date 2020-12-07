#include <stdio.h>      // fgets / fprintf / perror / clearerr
#include <stdlib.h>     // exit
#include <string.h>     // memset / memmove / strlen
#include <unistd.h>     // write / close
#include <sys/socket.h> // socket / setsockopt / bind
#include <netdb.h>      // gethostbyname / herror

#define SERVER_NAME "localhost"
#define SERVER_PORT 12345
#define NQUEUESIZE  5

int main ()
{
  int listener;
  int reuse;
  struct sockaddr_in  saddr;
  struct hostent     *hp;

  if ((listener = socket(PF_INET, SOCK_STREAM, 0)) < 0) {
    perror("socket(2)");
    exit(1);
  }

  reuse = 1;

  // アドレス再利用設定
  if (setsockopt(listener, SOL_SOCKET, SO_REUSEADDR, &reuse, sizeof(reuse)) < 0) {
    perror("setsockopt(2)");
    exit(1);
  }

  // ホスト名をIPアドレスへ変換
  if ((hp = gethostbyname(SERVER_NAME)) == NULL) {
    herror("gethostbyname(3)");
    exit(1);
  }

  // 通信プロトコル・ポート・アドレスの設定
  memset(&saddr, 0, sizeof(saddr));
  saddr.sin_family = PF_INET;
  saddr.sin_port   = htons(SERVER_PORT);
  memmove(&saddr.sin_addr, hp->h_addr_list[0], sizeof(saddr.sin_addr));
  saddr.sin_addr.s_addr = htonl(INADDR_ANY);

  if (bind(listener, (struct sockaddr *)&saddr, sizeof(saddr)) < 0) {
    perror("bind(2)");
    exit(1);
  }

  if (listen(listener, NQUEUESIZE)) {
    perror("listen(2)");
    exit(1);
  }

  for (;;) {
    int  connection;
    char msg[1024];
    int  msgsize;
    struct sockaddr_in caddr;
    socklen_t          caddr_len = sizeof(caddr);

    if ((connection = accept(listener, (struct sockaddr *)&caddr, &caddr_len)) < 0) {
      perror("accept(2)");
      exit(1);
    }

    while ((msgsize = read(connection, msg, sizeof(msg))) > 0) {
      write(connection, msg, msgsize);
    }

    if (shutdown(connection, SHUT_RDWR) < 0) {
      perror("shutdown(2)");
      exit(1);
    }

    if (close(connection) < 0) {
      perror("close(2)");
      exit(1);
    }
  }

  return 0;
}
