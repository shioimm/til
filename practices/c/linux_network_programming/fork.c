// 参照: Linuxネットワークプログラミング Chapter10 TCPサーバプログラミング 10-1

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <sys/wait.h>
#include <errno.h>

int main()
{
  int sock0;
  struct sockaddr_in addr;
  struct sockaddr_in client;
  socklen_t len;
  int sock;
  int pid, cpid;
  char buf[1024];
  int n;
  int status;

  sock0 = socket(AF_INET, SOCK_STREAM, 0);
  addr.sin_family = AF_INET;
  addr.sin_port = htons(12345);
  addr.sin_addr.s_addr = INADDR_ANY;
  bind(sock0, (struct sockaddr *)&addr, sizeof(addr));

  listen(sock0, 5);

  for (;;) {
    len = sizeof(client);
    sock = accept(sock0, (struct sockaddr *)&client, &len);

    pid = fork();

    if (pid == 0) {
      for (;;) {
        n = read(sock, buf, sizeof(buf));

        if (n == 0) {
          break;
        } else if (n < 0) {
          perror("read(2)");
          exit(1);
        }

        write(sock, buf, n);
        write(sock, "\n", 1);

        if (n <= sizeof(buf)) {
          break;
        }
      }

      shutdown(sock, SHUT_RDWR);
      close(sock);

      return 0;
    } else {
      while ((cpid = waitpid(-1, &status, WNOHANG)) > 0) {
        if (cpid < 0 && errno != ECHILD) {
          perror("waitpid");
          return 1;
        }
      }
    }
  }

  close(sock0);
  return 0;
}
