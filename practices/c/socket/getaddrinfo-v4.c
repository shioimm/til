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
  struct addrinfo hints, *res;
  struct sockaddr_in *s_in;
  char buf[INET_ADDRSTRLEN];
  int err;

  memset(&hints, 0, sizeof(hints));

  hints.ai_family = AF_INET;
  hints.ai_socktype = SOCK_STREAM;

  if ((err = getaddrinfo(hostname, NULL, &hints, &res)) != 0) {
    printf("error %d\n",err);
    return 1;
  }

  s_in = (struct sockaddr_in *)(res->ai_addr);
  inet_ntop(s_in->sin_family, &(s_in->sin_addr), buf, sizeof(buf));
  printf("ip address: %s\n", buf);

  freeaddrinfo(res);

  return 0;
}
