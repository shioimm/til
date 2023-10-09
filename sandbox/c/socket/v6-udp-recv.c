// Software Design 2021年5月号 ハンズオンTCP/IP

#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>

int main()
{
  int sock;
  struct sockaddr_in6 addr;
  struct sockaddr_in6 senderinfo;
  socklen_t addrlen;
  char buf[2048];
  char ipaddrstr[INET6_ADDRSTRLEN];
  int n;

  sock = socket(AF_INET6, SOCK_DGRAM, 0);

  addr.sin6_family = AF_INET6;
  addr.sin6_port   = htons(54321);
  addr.sin6_addr   = in6addr_any;

  if (bind(sock, (struct sockaddr *)&addr, sizeof(addr)) != 0) {
    perror("bind");
    return 1;
  }

  memset(buf, 0, sizeof(buf));

  addrlen = sizeof(senderinfo);

  n = recvfrom(sock, buf, sizeof(buf) - 1, 0, (struct sockaddr *)&senderinfo, &addrlen);

  inet_ntop(AF_INET6, &senderinfo.sin6_addr,ipaddrstr, sizeof(ipaddrstr));
  printf("UDP packet from : %s, port=%d\n", ipaddrstr, ntohs(senderinfo.sin6_port));

  write(fileno(stdout), buf, n);

  close(sock);

  return 0;
}
