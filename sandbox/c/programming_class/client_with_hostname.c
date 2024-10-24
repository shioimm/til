// 参照: 例解UNIX/Linuxプログラミング教室P317

#include <sys/types.h>  // socket, connect, inet_addr, read, write
#include <sys/socket.h> // socket, connect, inet_addr,  shutdown
#include <stdio.h>
#include <stdlib.h>
#include <string.h>     // memset, memmove
#include <netinet/in.h> // inet_addr
#include <arpa/inet.h>  // htons, inet_addr
#include <sys/uio.h>    // read, write
#include <unistd.h>     // close, read, write
#include <netdb.h>      // gethostbyname

#define SERVER_ADDR "127.0.0.1"
#define SERVER_NAME "localhost"
#define SERVER_PORT 12345

int main()
{
  int s, cc;
  struct sockaddr_in sa;
  struct hostent *hp;
  char buf[1024];

  if ((hp = gethostbyname(SERVER_NAME))  == NULL) {
    herror("gethostbyname");
    exit(1);
  }

  if ((s = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
    perror("socket");
    exit(1);
  }

  memset(&sa, 0, sizeof(sa));
  sa.sin_family      = AF_INET;
  sa.sin_port        = htons(SERVER_PORT);
  memmove(&sa.sin_addr, hp->h_addr_list[0], sizeof(sa.sin_addr));

  fprintf(stderr, "Connecting to the server...\n");

  if (connect(s, (struct sockaddr *)&sa, sizeof(sa)) < 0) {
    perror("connect");
    exit(1);
  }

  fprintf(stderr, "Connected.\n");
  fprintf(stderr, "Message from the server.\n\n");

  while ((cc = read(s, buf, sizeof(buf))) > 0) {
    write(1, buf, cc);
  }

  if (cc < 0) {
    perror("read");
    exit(1);
  }

  fprintf(stderr, "\nFinished receiving.\n");

  if (shutdown(s, SHUT_RDWR) < 0) {
    perror("shutdown");
    exit(1);
  }

  if (close(s) < 0) {
    perror("close");
    exit(1);
  }

  return 0;
}
