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

  if ((bind(sock, res->ai_addr, res->ai_addrlen)) < 0) {
    error();
  }

  fprintf(stdout, "Socket is successfully bound.\n");

  freeaddrinfo(res);

  exit(0);
}

// struct addrinfo {
//   int              ai_flags;     追加のオプション
//   int              ai_family;    アドレスファミリー
//   int              ai_socktype;  ソケット型
//   int              ai_protocol;  ソケットアドレスのプロトコル
//   socklen_t        ai_addrlen;   ソケットアドレスの長さ
//   struct sockaddr *ai_addr;      ソケットアドレスへのポインタ
//   char            *ai_canonname; ホストの公式な名前(ai_flagsにAI_CANONNAMEフラグが含まれている場合)
//   struct addrinfo *ai_next;      リンクリストの次の要素
// };
