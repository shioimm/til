// Software Design 2021年5月号 ハンズオンTCP/IP

#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <arpa/inet.h>

int main()
{
  int sock;
  struct addrinfo hints, *res;
  struct group_req greq;
  struct sockaddr_in addr;
  struct sockaddr_in senderinfo;
  socklen_t addrlen;
  int n;
  int err;
  char buf[2048];
  char ipaddrstr[INET_ADDRSTRLEN];

  sock = socket(AF_INET, SOCK_DGRAM, 0);
  addr.sin_family = AF_INET;
  addr.sin_port = htonl(54321);
  addr.sin_addr.s_addr = INADDR_ANY;

  bind(sock, (struct sockaddr *)&addr, sizeof(addr));

  memset(&hints, 0, sizeof(hints));

  hints.ai_family = AF_INET;
  hints.ai_socktype = SOCK_DGRAM;
  err = getaddrinfo("239.192.100.100", NULL, &hints, &res);

  if (err != 0) {
    printf("getaddrinfo: %s\n", gai_strerror(err));
    return 1;
  }

  memset(&greq, 0, sizeof(greq));
  greq.gr_interface = 0;

  memcpy(&greq.gr_group, res->ai_addr, res->ai_addrlen);
  freeaddrinfo(res);

  if (setsockopt(sock, IPPROTO_IP, MCAST_JOIN_GROUP, (char *)&greq, sizeof(greq)) != 0) {
    perror("setsockopt");
    return 1;
  }

  memset(buf, 0, sizeof(buf));

  addrlen = sizeof(senderinfo);

  n = recvfrom(sock, buf, sizeof(buf) - 1, 0, (struct sockaddr *)&senderinfo, &addrlen);

  inet_ntop(AF_INET, &senderinfo.sin_addr, ipaddrstr, sizeof(ipaddrstr));
  printf("UDP packet from: %s, port=%d\n", ipaddrstr, ntohs(senderinfo.sin_port));

  write(fileno(stdout), buf, n);

  close(sock);

  return 0;
}
