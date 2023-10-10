// Software Design 2021年5月号 ハンズオンTCP/IP

#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <net/if.h>

int main()
{
  int sock;
  struct sockaddr_in6 addr;
  int n;
  int ifidx;

  sock = socket(AF_INET6, SOCK_DGRAM, 0);
  addr.sin6_family = AF_INET6;
  addr.sin6_port = htonl(54321);
  inet_pton(AF_INET6, "ff0e::9999:9999", &addr.sin6_addr);
  ifidx = if_nametoindex("eth0");

  if (setsockopt(sock, IPPROTO_IPV6, IPV6_MULTICAST_IF, (char *)&ifidx, sizeof(ifidx)) != 0) {
    perror("setsockopt");
    return 1;
  }

  n = sendto(sock, "HELLO", 5, 0, (struct sockaddr *)&addr, sizeof(addr));

  if (n < 1) {
    perror("sendto");
    return 1;
  }

  close(sock);

  return 0;
}
