// Software Design 2021年5月号 ハンズオンTCP/IP

#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>

int main(int argc, char *argv[])
{
  int sock;
  struct sockaddr_in senderinfo;
  struct sockaddr_in myaddr;
  struct addrinfo hints, *res;
  socklen_t myaddr_sz;
  socklen_t addrlen;
  int n;
  char buf[2048];
  char ipaddrstr[INET_ADDRSTRLEN];

  if (argc != 2) {
    fprintf(stderr, "Usage: %s destination\n", argv[0]);
    return 1;
  }

  sock = socket(AF_INET, SOCK_DGRAM, 0);
  memset(&hints, 0, sizeof(hints));
  hints.ai_family = AF_INET;
  hints.ai_socktype = SOCK_DGRAM;

  if (getaddrinfo(argv[1], "54321", &hints, &res) != 0) {
    perror("getaddrinfo");
    return 1;
  }

  n = sendto(sock, "HELLO", 5, 0, res->ai_addr, res->ai_addrlen);

  if (n < 1) {
    perror("sendto");
    return 1;
  }

  myaddr_sz = sizeof(myaddr);

  if (getsockname(sock, (struct sockaddr *)&myaddr, &myaddr_sz) != 0) {
    perror("getsockname");
    return 1;
  }

  printf("my port number is %d\n", ntohs(myaddr.sin_port));

  addrlen = sizeof(senderinfo);
  n = recvfrom(sock, buf, sizeof(buf) - 1, 0, (struct sockaddr *)&senderinfo, &addrlen);

  inet_ntop(AF_INET, &senderinfo.sin_addr, ipaddrstr, sizeof(ipaddrstr));
  printf("UDP packet from: %s, port=%d\n", ipaddrstr, ntohs(senderinfo.sin_port));

  write(fileno(stdout), buf, n);

  close(sock);

  return 0;
}
