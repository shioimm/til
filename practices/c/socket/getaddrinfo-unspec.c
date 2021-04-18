// Software Design 2021年5月号 ハンズオンTCP/IP

#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <arpa/inet.h>

int main()
{
  char *hostname = "localhost";
  struct addrinfo hints, *res, *res0;
  struct sockaddr_in *s_in;
  struct sockaddr_in6 *s_in6;
  char buf[INET6_ADDRSTRLEN];
  int err;

  memset(&hints, 0, sizeof(hints));

  hints.ai_family = PF_UNSPEC; // IPv4 / IPv6両方の名前解決を行う
  hints.ai_socktype = SOCK_STREAM;

  if ((err = getaddrinfo(hostname, NULL, &hints, &res0)) != 0) {
    printf("error %d\n",err);
    return 1;
  }

  for (res = res0; res != NULL; res = res->ai_next) {
    switch (res->ai_addr->sa_family) {
      case AF_INET:
        s_in = (struct sockaddr_in *)(res->ai_addr);
        inet_ntop(AF_INET, &(s_in->sin_addr), buf, sizeof(buf));
        printf("ipv4 address: %s\n", buf);

        break;
      case AF_INET6:
        s_in6 = (struct sockaddr_in6 *)(res->ai_addr);
        inet_ntop(AF_INET6, &(s_in6->sin6_addr), buf, sizeof(buf));
        printf("ipv6 address: %s\n", buf);

        break;
      default:
        break;
    }
  }
  freeaddrinfo(res);

  return 0;
}
