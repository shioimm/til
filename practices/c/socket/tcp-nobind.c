// Software Design 2021年5月号 ハンズオンTCP/IP

#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

int main()
{
  int  sock0;
  int  sock;
  struct sockaddr_in peer;
  struct sockaddr_in myaddr;
  socklen_t peerlen;
  socklen_t myaddrlen;

  sock0 = socket(AF_INET, SOCK_STREAM, 0);

  if (listen(sock0, 5) != 0) {
    perror("listen");
    return 1;
  }

  myaddrlen = sizeof(myaddr);

  if (getsockname(sock0, (struct sockaddr *)&myaddr, &myaddrlen) != 0) {
    perror("getsockname");
    return 1;
  }

  printf("my port number is %d\n", ntohs(myaddr.sin_port));

  peerlen = sizeof(peer);
  sock = accept(sock0, (struct sockaddr *)&peer, &peerlen);

  if (sock < 0) {
    perror("accept");
    return 1;
  }

  write(sock, "HOGE\n", 5);

  close(sock);
  close(sock0);

  return 0;
}
