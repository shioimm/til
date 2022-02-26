#include <sys/socket.h> // socket(2), bind(2), setsockopt(2), listen(2), accept(2), shutdown(2)
                        // getaddrinfo(3), freeaddrinfo(3), gai_strerror(3)
#include <sys/types.h>  // getaddrinfo(3), freeaddrinfo(3), gai_strerror(3)
#include <netdb.h>      // getaddrinfo(3), freeaddrinfo(3), gai_strerror(3)
#include <string.h>     // memset(3), strlen(3)
#include <stdio.h>      // perror(3)
#include <stdlib.h>     // exit(3)
#include <unistd.h>     // read(2), write(2)

#define HOST "localhost"
#define PORT 12345
#define NQUEUESIZE 5
#define MSGBUFSIZE 1024

int main()
{
  // サーバーアドレス情報設定
  struct addrinfo hints, *res;
  int addrinfoerr;

  memset(&hints, 0, sizeof(struct addrinfo));
  hints.ai_family   = AF_INET;
  hints.ai_socktype = SOCK_STREAM;
  hints.ai_flags    = AI_PASSIVE;

  if ((addrinfoerr = getaddrinfo(NULL, "12345", &hints, &res)) < 0) {
    gai_strerror(addrinfoerr);
  }

  // サーバーソケットの作成
  int server_sock;

  if ((server_sock = socket(res->ai_family, res->ai_socktype, res->ai_protocol)) < 0) {
    perror("socket(2)");
    exit(1);
  }

  // サーバーアドレス再利用設定
  int reuse = 1;

  if (setsockopt(server_sock, SOL_SOCKET, SO_REUSEADDR, &reuse, sizeof(reuse)) < 0) {
    perror("setsockopt(2)");
    exit(1);
  }

  // bind
  if (bind(server_sock, res->ai_addr, res->ai_addrlen) < 0) {
    perror("bind(2)");
    exit(1);
  }

  // アドレス情報を解放
  freeaddrinfo(res);

  // listen
  if (listen(server_sock, NQUEUESIZE) < 0) {
    perror("listen(2)");
    exit(1);
  }

  int client_sock;
  struct sockaddr_storage client_addr;
  socklen_t client_addr_len = sizeof(client_addr);

  char msg[MSGBUFSIZE];
  int  msg_size;

  for (;;) {
    // accept
    if ((client_sock = accept(server_sock, (struct sockaddr *)&client_addr, &client_addr_len)) < 0) {
      perror("accept(2)");
      exit(1);
    }

    // read / write
    if ((msg_size = read(client_sock, msg, MSGBUFSIZE)) < 0) {
      perror("read(2)");
      exit(1);
    }

    puts("--- Received ----");

    while (msg_size > 0) {
      if (write(client_sock, msg, msg_size) != msg_size) {
        perror("write(2)");
        exit(1);
      }

      puts(msg);

      if ((msg_size = read(client_sock, msg, MSGBUFSIZE)) < 0) {
        perror("read(2)");
        exit(1);
      }
    }

    // shutdown
    if (shutdown(client_sock, SHUT_RDWR) < 0) {
      perror("shutdown(2)");
      exit(1);
    }

    // close(2)
    if (close(client_sock) < 0) {
      perror("close");
      exit(1);
    }
  }

  return 0;
}
