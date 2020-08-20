#include <stdio.h>  // perror()
#include <stdlib.h> // exit()
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>  // ネットワークデータベース操作
#include <string.h> // memset()

// #include <sys/types.h>
// #include <sys/socket.h>
// int socket(int domain, int type, int protocol);
// int bind(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
// int listen(int sockfd, int backlog);

void error()
{
  perror("Failed");
  exit(1);
}

int main()
{
  int sock;
  int addrinfo;
  struct addrinfo hints, *res;
  const char *hostname = "localhost";

  if ((sock = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
    error();
  }

  fprintf(stdout, "File discripter number is %d.\n", sock);

  memset(&hints, 0, sizeof(struct addrinfo));
  hints.ai_family = AF_INET;       // アドレスファミリー
  hints.ai_socktype = SOCK_STREAM; // 推奨のソケット型

  getaddrinfo(hostname, NULL, &hints, &res);

  if (bind(sock, res->ai_addr, res->ai_addrlen) < 0) {
    error();
  }

  fprintf(stdout, "Socket is successfully bound.\n");

  freeaddrinfo(res);

  if (listen(sock, 5) < 0) {
    error();
  }

  fprintf(stdout, "Socket is listening.\n");

  // TODO:
  // listen用のsocketとファイル実行用のsocketを分ける
  // fork()で複数回acceptできるようにする

  if (close(sock) < 0) {
    error();
  }

  fprintf(stdout, "Socket is successfully closed.\n");

  exit(0);
}
