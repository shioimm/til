#include <sys/types.h>
#include <sys/socket.h>
#include <stdio.h>
#include <stdlib.h>    // exit
#include <string.h>
#include <arpa/inet.h> // sockaddr_in, inet_pton
#include <unistd.h>    // read, write, close
#include <netdb.h>     // addrinfo, getaddrinfo, freeaddrinfo

struct addrinfo *next_addrinfo(struct addrinfo *res)
{
  if (res->ai_next) {
    return res->ai_next;
  } else {
    return NULL;
  }
}

int main()
{
  char *hostname = "localhost";
  char *service  = "9292";
  struct addrinfo hints, *res0, *res;
  int err;
  int sock;

  memset(&hints, 0, sizeof(hints));
  hints.ai_socktype = SOCK_STREAM;
  hints.ai_family = PF_UNSPEC;

  if ((err = getaddrinfo(hostname, service, &hints, &res0)) != 0) {
    printf("hostname resolution error %d\n", err);
    return 1;
  }

  res = res0;

  while (1) {
    sock = socket(res->ai_family, res->ai_socktype, res->ai_protocol);

    if (sock < 0) continue;

    if (connect(sock, res->ai_addr, res->ai_addrlen) != 0) {
      close(sock);
      res = next_addrinfo(res);

      if (res == NULL) {
        printf("failed to connect\n");
        return 1;
      } else {
        continue;
      }
    }

    break; // 接続に成功
  }

  freeaddrinfo(res0);

  char buf[1024];

  snprintf(buf, sizeof(buf), "GET / HTTP/1.0\r\n\r\n");
  write(sock, buf, strnlen(buf, sizeof(buf)));

  memset(buf, 0, sizeof(buf));
  read(sock, buf, sizeof(buf));
  printf("%s", buf);

  close(sock);

  return 0;
}
