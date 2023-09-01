#include <sys/types.h>
#include <sys/socket.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>

// TODO アドレス解決してみる

#define SERVER_ADDR "127.0.0.1"
#define SERVER_PORT 9292

int main()
{
  int sock;
  struct sockaddr_in sockaddr;
  char buf[1024];

  if ((sock = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
    perror("socket");
    exit(1);
  }

  memset(&sockaddr, 0, sizeof(sockaddr));
  sockaddr.sin_family      = AF_INET;
  sockaddr.sin_port        = htons(SERVER_PORT);
  sockaddr.sin_addr.s_addr = inet_addr(SERVER_ADDR);

  if (connect(sock, (struct sockaddr *)&sockaddr, sizeof(sockaddr)) < 0) {
    perror("connect");
    exit(1);
  }

  snprintf(buf, sizeof(buf), "GET / HTTP/1.0\r\n\r\n");
  write(sock, buf, strnlen(buf, sizeof(buf)));

  memset(buf, 0, sizeof(buf));
  read(sock, buf, sizeof(buf));
  printf("%s", buf);

  close(sock);

  return 0;
}
