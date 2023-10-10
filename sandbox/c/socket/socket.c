#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/socket.h>

// #include <sys/types.h>
// #include <sys/socket.h>
// int socket(int domain, int type, int protocol);

int main()
{
  int sock = socket(AF_INET, SOCK_STREAM, 1);

  if (sock < 0) {
    perror("Failed"); // fprintf(stderr, "Failed: %s\d", strerror(errono));
    exit(1);
  }

  fprintf(stdout, "File discripter number is %d\n", sock);

  exit(0);
}
