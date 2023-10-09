// Software Design 2021年5月号 ハンズオンTCP/IP

#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>

int main()
{
  int  sock0;
  struct sockaddr_in client;
  socklen_t clen;
  int  sock;
  struct addrinfo hints, *res;
  int err;

  memset(&hints, 0, sizeof(hints));
  hints.ai_family   = AF_INET;
  hints.ai_flags    = AI_PASSIVE;
  hints.ai_socktype = SOCK_STREAM;
  err = getaddrinfo(NULL, "54321", &hints, &res);
  if (err != 0) {
    printf("getaddrinfo : %s\n", gai_strerror(err));
    return 1;
  }

  sock0 = socket(res->ai_family, res->ai_socktype, 0);
  if (sock0 < 0) {
    perror("socket");
    return 1;
  }

  if (bind(sock0, res->ai_addr, res->ai_addrlen) != 0) {
    perror("bind");
    return 1;
  }

  freeaddrinfo(res);

  listen(sock0, 5);

  clen = sizeof(client);
  sock = accept(sock0, (struct sockaddr *)&client, &clen);

  write(sock, "HELLO\n", 5);

  close(sock);
  close(sock0);

  return 0;
}
