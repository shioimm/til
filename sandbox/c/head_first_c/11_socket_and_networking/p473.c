// Head First C P473

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <sys/socket.h>
#include <arpa/inet.h>

void error(char *msg)
{
  fprintf(stderr, "%s: %s\n", msg, strerror(errno));
  exit(1);
}

int main(int argc, char *argv[])
{
  char *advice[] = {
    "Take smaller bites\n",
    "Go for the tight jeans\n",
    "One word: inappropriate\n",
    "You might want to rethink that haircut\n"
  };

  int listener_d = socket(PF_INET, SOCK_STREAM, 0);

  if (listener_d == -1) {
    error("Can't create socket");
  }

  struct sockaddr_in name;
  name.sin_family = PF_INET;
  name.sin_port = (in_port_t)htons(30000);
  name.sin_addr.s_addr = htonl(INADDR_ANY);

  if ((bind(listener_d, (struct sockaddr *)&name, sizeof(name))) == -1) {
    error("Can't bind");
  }

  if ((listen(listener_d, 10)) == -1) {
    error("Can't listen");
  }

  puts("listening...");

  while (1) {
    struct sockaddr_storage client_addr;
    unsigned int address_size = sizeof(client_addr);

    int connect_d = accept(listener_d, (struct sockaddr *)&client_addr, &address_size);

    char *msg = advice[rand() % 5];

    if ((send(connect_d, msg, strlen(msg), 0)) == -1) {
      error("Can't send");
    }

    if ((close(connect_d)) == -1) {
      error("Can't close");
    }
  }

  return 0;
}
