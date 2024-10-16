#include <sys/socket.h> // socket(2), bind(2), setsockopt(2), listen(2), accept(2), shutdown(2)
                        // getaddrinfo(3), freeaddrinfo(3), gai_strerror(3)
#include <sys/types.h>  // getaddrinfo(3), freeaddrinfo(3), gai_strerror(3)
#include <netdb.h>      // getaddrinfo(3), freeaddrinfo(3), gai_strerror(3)
#include <string.h>     // memset(3), strlen(3)
#include <stdio.h>      // perror(3)
#include <stdlib.h>     // exit(3)
#include <unistd.h>     // read(2), write(2)

#define HOST "localhost"
#define PORT "12345"
#define NQUEUESIZE 5
#define MAXMSGSIZE 1024

int main()
{
  // サーバーアドレス情報設定
  struct addrinfo server_addr_hints, *server_addr, *server_addr_tmp;
  int addrinfoerr;

  memset(&server_addr_hints, 0, sizeof(struct addrinfo));
  server_addr_hints.ai_family   = AF_INET; // 便宜上AF_INETにする (AF_UNSPECにするとプロトコル独立)
  server_addr_hints.ai_socktype = SOCK_STREAM;
  server_addr_hints.ai_flags    = AI_PASSIVE;

  if ((addrinfoerr = getaddrinfo(HOST, PORT, &server_addr_hints, &server_addr)) < 0) {
    gai_strerror(addrinfoerr);
  }

  int listener;

  for (server_addr_tmp = server_addr; server_addr_tmp; server_addr_tmp = server_addr_tmp->ai_next) {
    // サーバーソケットの作成
    listener = socket(server_addr_tmp->ai_family, server_addr_tmp->ai_socktype, server_addr_tmp->ai_protocol);

    if (listener < 0) {
      continue;
    }

    // bind
    if (bind(listener, server_addr_tmp->ai_addr, server_addr_tmp->ai_addrlen) < 0) {
      close(listener);
      continue;
    }
  }

  // アドレス情報を解放
  freeaddrinfo(server_addr);

  // サーバーアドレス再利用設定
  int reuse = 1;

  if (setsockopt(listener, SOL_SOCKET, SO_REUSEADDR, &reuse, sizeof(reuse)) < 0) {
    perror("setsockopt(2)");
    exit(1);
  }

  // listen
  if (listen(listener, NQUEUESIZE) < 0) {
    perror("listen(2)");
    exit(1);
  }

  int conn;
  struct sockaddr_storage client_addr;
  socklen_t client_addr_len = sizeof(client_addr);

  char received_msg[MAXMSGSIZE];
  int  received_msg_size;

  for (;;) {
    // accept
    if ((conn = accept(listener, (struct sockaddr *)&client_addr, &client_addr_len)) < 0) {
      perror("accept(2)");
      exit(1);
    }

    // read / write
    if ((received_msg_size = read(conn, received_msg, MAXMSGSIZE)) < 0) {
      perror("read(2)");
      exit(1);
    }

    puts("--- Received ----");

    while (received_msg_size > 0) {
      if (write(conn, received_msg, received_msg_size) != received_msg_size) {
        perror("write(2)");
        exit(1);
      }

      printf("%.*s", received_msg_size, received_msg);
      memset(received_msg, 0, received_msg_size);

      if ((received_msg_size = read(conn, received_msg, MAXMSGSIZE)) < 0) {
        perror("read(2)");
        exit(1);
      }
    }

    // close(2)
    if (close(conn) < 0) {
      perror("close");
      exit(1);
    }
  }

  return 0;
}

