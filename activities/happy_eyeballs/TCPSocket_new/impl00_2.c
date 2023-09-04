#include <sys/types.h>
#include <sys/socket.h>
#include <stdio.h>
#include <stdlib.h>    // exit
#include <string.h>
#include <arpa/inet.h> // sockaddr_in, inet_pton
#include <unistd.h>    // read, write, close
#include <netdb.h>     // addrinfo, getaddrinfo, freeaddrinfo

struct selectable_addrinfo {
  int              ai_family;
  int              ai_socktype;
  int              ai_protocol;
  struct sockaddr *ai_addr;
  socklen_t        ai_addrlen;
};

int main()
{
  char *hostname = "localhost";
  char *service  = "9292";
  struct addrinfo hints, *res0, *res;
  struct selectable_addrinfo selectable_addrinfos[10];
  int err;
  int sock;

  memset(&hints, 0, sizeof(hints));
  hints.ai_socktype = SOCK_STREAM;
  hints.ai_family = PF_UNSPEC;

  if ((err = getaddrinfo(hostname, service, &hints, &res0)) != 0) {
    printf("hostname resolution error %d\n", err);
    return 1;
  }

  int index = 0;
  for (res = res0; res != NULL; res = res->ai_next) {
    selectable_addrinfos[index].ai_family   = res->ai_family;
    selectable_addrinfos[index].ai_socktype = res->ai_socktype;
    selectable_addrinfos[index].ai_protocol = res->ai_protocol;
    selectable_addrinfos[index].ai_addr     = res->ai_addr;
    selectable_addrinfos[index].ai_addrlen  = res->ai_addrlen;
    index++;
  }

  for (int i = 0; i < 10; i++) {
    struct selectable_addrinfo ai = selectable_addrinfos[i];
    sock = socket(ai.ai_family, ai.ai_socktype, ai.ai_protocol);

    if (sock < 0) continue;

    if (connect(sock, ai.ai_addr, ai.ai_addrlen) != 0) {
      close(sock);
      continue;
    } else {
      break;
    }
  }

  freeaddrinfo(res0);
  freeaddrinfo(res);

  char buf[1024];

  snprintf(buf, sizeof(buf), "GET / HTTP/1.0\r\n\r\n");
  write(sock, buf, strnlen(buf, sizeof(buf)));

  memset(buf, 0, sizeof(buf));
  read(sock, buf, sizeof(buf));
  printf("%s", buf);

  close(sock);

  return 0;
}
