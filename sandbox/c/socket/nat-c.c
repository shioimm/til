// Software Design 2021年5月号 ハンズオンTCP/IP

#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>

int main(int argc, char *argv[])
{
  int sock;
  struct addrinfo hints, *res;
  int n;
  int err;
  struct sockaddr_in addr;

  if (argc != 3 && argc != 4) {
    fprintf(stderr, "Usage: %s destip destport [srcport]\n", argv[0]);
    return 1;
  }

  sock = socket(AF_INET, SOCK_DGRAM, 0);
  memset(&hints, 0, sizeof(hints));
  hints.ai_family = AF_INET;
  hints.ai_socktype = SOCK_DGRAM;

  if (err = getaddrinfo(argv[1], argv[2], &hints, &res) != 0) {
    printf("error %d\n", err);
    return 1;
  }

  if (argc == 4) {
    memset(&addr, 0, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_port = htonl(atoi(argv[3]));

    if (bind(sock, (struct sockaddr *)&addr, sizeof(addr)) != 0) {
      perror("bind");
      return 1;
    }
  }

  n = sendto(sock, "HELLO", 5, 0, res->ai_addr, res->ai_addrlen);

  if (n < 1) {
    perror("sendto");
    return 1;
  }

  close(sock);

  return 0;
}
