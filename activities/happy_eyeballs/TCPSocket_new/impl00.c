#include <sys/types.h>
#include <sys/socket.h>
#include <stdio.h>
#include <stdlib.h>    // exit
#include <string.h>
#include <arpa/inet.h> // sockaddr_in, inet_pton
#include <unistd.h>    // read, write, close

// TODO アドレス解決してみる

#define SERVER_ADDR "127.0.0.1"
#define SERVER_PORT 9292

int main()
{
  int sock;
  struct sockaddr_in serveraddr;
  char buf[1024];

  if ((sock = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
    perror("socket(2)");
    exit(1);
  }

  memset(&serveraddr, 0, sizeof(serveraddr));
  serveraddr.sin_family      = AF_INET;
  serveraddr.sin_port        = htons(SERVER_PORT);
  inet_pton(AF_INET, SERVER_ADDR, &serveraddr.sin_addr.s_addr);

  if (connect(sock, (struct sockaddr *)&serveraddr, sizeof(serveraddr)) < 0) {
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
