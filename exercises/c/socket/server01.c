// socketライブラリ
//
// #include <sys/types.h>
// #include <sys/socket.h>
// int     socket(int domain,
//                int type,
//                int protocol);
// int     bind(int sd,
//              const struct sockaddr *name,
//              socklen_t namelen);
// int     listen(int sd,
//                int backlog);
// int     accept(int sd,
//                struct sockaddr *addr,
//                socklen_t *addrlen);
// ssize_t recv(int sockfd,
//              void *buf,
//              size_t len,
//              int flags);
// ssize_t send(int sockfd,
//              const void *buf,
//              size_t len,
//              int flags);
// int     shutdown(int sd, int how);

// アドレス
// 引用: https://www.infra.jp/programming/network_programming_2.html
//
// struct addrinfo {
//   int ai_flags;                 /* Input flags.  */
//   int ai_family;                /* Protocol family for socket.  */
//   int ai_socktype;              /* Socket type.  */
//   int ai_protocol;              /* Protocol for socket.  */
//   socklen_t ai_addrlen;         /* Length of socket address.  */
//   struct sockaddr *ai_addr;     /* Socket address for socket.  */
//   char *ai_canonname;           /* Canonical name for service location.  */
//   struct addrinfo *ai_next;     /* Pointer to next in list.  */
// };
//
// struct sockaddr_in {
//   sa_family_t sin_family;
//   in_port_t sin_port;
//   struct in_addr sin_addr;
//   char sin_zero[8];
// };
//
// #include <sys/types.h>
// #include <sys/socket.h>
// #include <netdb.h>
//
// int   getaddrinfo(const char *node,
//                   const char *service,
//                   const struct addrinfo *hints,
//                   struct addrinfo **res);
// void  freeaddrinfo(struct addrinfo *res);
// const char *gai_strerror(int errcode);

#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h> // for open
#include <unistd.h> // for close

int main()
{
  const char *host = "localhost";

  struct addrinfo hints, *res;
  int    sock;
  int    errcode;

  memset(&hints, 0, sizeof(hints));
  hints.ai_family = AF_INET;
  hints.ai_socktype = SOCK_STREAM;
  hints.ai_flags = AI_PASSIVE;

  if ((errcode = getaddrinfo(host, NULL, &hints, &res)) < 0) {
    exit(1);
  }

  if ((sock = socket(res->ai_family, res->ai_socktype, res->ai_protocol)) < 0) {
    fprintf(stderr, "getaddrinfo():%s\n", gai_strerror(errcode));
    freeaddrinfo(res);
    exit(1);
  }

  if (bind(sock, res->ai_addr, res->ai_addrlen) < 0) {
    perror("bind");
    close(sock);
    freeaddrinfo(res);
    exit(1);
  }

  if (listen(sock, 5) < 0) {
    perror("listen");
    close(sock);
    freeaddrinfo(res);
    exit(1);
  }

  send(sock, "Hello\n", (size_t)7, 0);

  freeaddrinfo(res);
  exit(0);
}
