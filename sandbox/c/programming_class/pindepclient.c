// 参照: 例解UNIX/Linuxプログラミング教室P320

#include <sys/types.h>  // socket, connect, read, write, freeaddrinfo, getaddrinfo, gai_strerror
#include <sys/socket.h> // socket, connect, shutdown, freeaddrinfo, getaddrinfo, gai_strerror
#include <stdio.h>
#include <stdlib.h>
#include <string.h>     // memset
#include <sys/uio.h>    // read, write
#include <unistd.h>     // close, read, write
#include <netdb.h>      // reeaddrinfo, getaddrinfo, gai_strerror

char *httpreq = "GET / HTTP/1.0 \r\n\r\n";

int main()
{
  int s, cc;
  struct addrinfo hints, *addrs;
  char buf[1024];

  memset(&hints, 0, sizeof(hints));
  hints.ai_family   = AF_UNSPEC;
  hints.ai_socktype = SOCK_STREAM;

  if ((cc = getaddrinfo("www.titech.ac.jp", "http", &hints, &addrs)) != 0) {
    fprintf(stderr, "getaddrinfo' %s\n", gai_strerror(cc));
  }

  if ((s = socket(addrs->ai_family, addrs->ai_socktype, addrs->ai_protocol)) < 0) {
    perror("socket");
    exit(1);
  }

  if (connect(s, addrs->ai_addr, addrs->ai_addrlen) < 0) {
    perror("connect");
    exit(1);
  }

  freeaddrinfo(addrs);

  write(s, httpreq, strlen(httpreq));

  while ((cc = read(s, buf, sizeof(buf))) > 0) {
    write(1, buf, cc);
  }

  shutdown(s, SHUT_RDWR);
  close(s);

  return 0;
}
