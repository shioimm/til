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
  struct sockaddr_in addr;
  struct sockaddr_in senderinfo;
  socklen_t addrlen;
  char buf[2048];
  char ipaddrstr[INET_ADDRSTRLEN];
  int n;

  sock = socket(AF_INET, SOCK_DGRAM, 0);

  addr.sin_family      = AF_INET;
  addr.sin_port        = htons(54321);
  addr.sin_addr.s_addr = INADDR_ANY;

  if (bind(sock, (struct sockaddr *)&addr, sizeof(addr)) != 0) {
    perror("bind");
    return 1;
  }

  memset(buf, 0, sizeof(buf));

  addrlen = sizeof(senderinfo);

  n = recvfrom(sock, buf, sizeof(buf) - 1, 0, (struct sockaddr *)&senderinfo, &addrlen);

  inet_ntop(AF_INET, &senderinfo.sin_addr,ipaddrstr, sizeof(ipaddrstr));
  printf("UDP packet from : %s, port=%d\n", ipaddrstr, ntohs(senderinfo.sin_port));

  write(fileno(stdout), buf, n);

  close(sock);

  return 0;
}
