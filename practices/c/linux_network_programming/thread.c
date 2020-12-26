// 参照: Linuxネットワークプログラミング Chapter10 TCPサーバプログラミング 10-2

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <pthread.h>
#include <errno.h>

struct clientdata {
  int sock;
  struct sockaddr_in saddr;
};

void *threadFunc(void *data) {
  int sock;
  struct clientdata *cdata = data;
  char buf[1024];
  int n;

  if (data == NULL) {
    return (void *)-1;
  }

  sock = cdata->sock;

  n = read(sock, buf, sizeof(buf));
  if (n < 0) {
    perror("read(2)");
    goto err;
  }

  n = write(sock, buf, n);
  if (n < 0) {
    perror("write(2)");
    goto err;
  }

  if (close(sock) != 0) {
    perror("close(2)");
    goto err;
  }

  free(data);
  return NULL;

err:
  free(data);
  return (void *)-1;
}

int main()
{
  int sock0;
  struct sockaddr_in addr;
  socklen_t len;
  pthread_t th;
  struct clientdata *cdata;

  sock0 = socket(AF_INET, SOCK_STREAM, 0);
  addr.sin_family = AF_INET;
  addr.sin_port = htons(12345);
  addr.sin_addr.s_addr = INADDR_ANY;
  bind(sock0, (struct sockaddr *)&addr, sizeof(addr));

  listen(sock0, 5);

  for (;;) {
    cdata = malloc(sizeof(struct clientdata));
    if (cdata == NULL) {
      perror("malloc");
      return 1;
    }

    len = sizeof(cdata->saddr);
    cdata->sock = accept(sock0,(struct sockaddr *)&cdata->saddr, &len);

    if (pthread_create(&th, NULL, threadFunc, cdata) != 0) {
      perror("pthread_create");
      return 1;
    }

    if (pthread_detach(th) != 0) {
      perror("pthread_detach");
      return 1;
    }
  }

  close(sock0);
  return 0;
}
