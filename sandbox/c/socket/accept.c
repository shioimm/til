#include <sys/socket.h> /* ソケット */
#include <arpa/inet.h>  /* インターネットアドレスを作成 */
#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

// #include <sys/types.h>
// #include <sys/socket.h>
// int socket(int domain, int type, int protocol);
// int bind(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
// int listen(int sockfd, int backlog);
// int accept(int sockfd, struct sockaddr *addr, socklen_t *addrlen);

// struct sockaddr_in {
//   u_char  sin_len;
//   u_char  sin_family;
//   u_short sin_port;
//   struct  in_addr sin_addr;
//   char    sin_zero[8];
// };

void error()
{
  perror("Failed.");
  exit(1);
}

int main()
{
  int sock;
  struct sockaddr_in addr;

  if ((sock = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
    error();
  }

  fprintf(stdout, "File discripter number is %d.\n", sock);

  addr.sin_family = AF_INET;
  addr.sin_port = (in_port_t)htons(30000);
  addr.sin_addr.s_addr = htonl(INADDR_ANY); // bind()に用いる任意のアドレス

  if (bind(sock, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
    error();
  }

  fprintf(stdout, "Socket is successfully bound.\n");

  if (listen(sock, 10) < 0) {
    error();
  }

  fprintf(stdout, "Socket is listening.\n");

  struct sockaddr_storage client_addr; // 接続相手のソケットのアドレス
  unsigned int address_size = sizeof(client_addr);

  if ((sock = accept(sock, (struct sockaddr *)&client_addr, &address_size)) < 0 ) {
    error();
  }

  send(sock, "Hello\n", 7, 0);

  if (close(sock) < 0) {
    error();
  }

  fprintf(stdout, "Socket is successfully closed.\n");

  exit(0);
}
