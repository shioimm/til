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
  int n;

  sock = socket(AF_INET6, SOCK_DGRAM, 0);

  addr.sin6_family = AF_INET6;
  addr.sin6_port   = htons(54321);
  inet_pton(AF_INET6, "::1", &addr.sin6_addr);

  n = sendto(sock, "HELLO", 5, 0,(struct sockaddr *)&addr, sizeof(addr));
  if (n < 1) {
    perror("sendto");
    return 1;
  }

  close(sock);

  return 0;
}
