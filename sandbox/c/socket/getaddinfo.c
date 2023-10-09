#include <stdio.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <netdb.h>  // ネットワークデータベース操作
#include <string.h> // memset()

// struct addrinfo {
//     int              ai_flags;
//     int              ai_family;
//     int              ai_socktype;
//     int              ai_protocol;
//     socklen_t        ai_addrlen;
//     struct sockaddr *ai_addr;
//     char            *ai_canonname;
//     struct addrinfo *ai_next;
// };
//
// int getaddrinfo(const char *node,
//                 const char *service,
//                 const struct addrinfo *hints,
//                 struct addrinfo **res);
//
// void freeaddrinfo(struct addrinfo *res);
//
// const char *gai_strerror(int errcode);

int main()
{
  int addrinfo;
  const char *hostname = "localhost";
  struct addrinfo hints, *res;

  memset(&hints, 0, sizeof(struct addrinfo));
  hints.ai_family = AF_UNSPEC;
  hints.ai_socktype = SOCK_STREAM;

  getaddrinfo(hostname, NULL, &hints, &res);

  printf("ai_flags:    %d\n", res->ai_flags);
  printf("ai_family:   %d\n", res->ai_family);
  printf("ai_socktype: %d\n", res->ai_socktype);
  printf("ai_protocol: %d\n", res->ai_protocol);
  printf("ai_addrlen:  %d\n", (int)res->ai_addrlen);

  freeaddrinfo(res);

  return 0;
}
