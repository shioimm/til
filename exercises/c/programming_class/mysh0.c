// 参照: 例解UNIX/Linuxプログラミング教室P209

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/wait.h> // wait, WIFEXITED, WEXITSTATUS
#include <unistd.h>
#include "mysub.h"

int main(int argc, char *argv[])
{
  int status;
  char cmd[1024];

  for (;;) {
    getstr("@ ", cmd, sizeof(cmd));

    if (fork() == 0) {
      execlp(cmd, cmd, (char *)0);
      perror(cmd);
      exit(1);
    } else {
      if (wait(&status) == (pid_t) - 1) {
        perror("wait");
        exit(1);
      }
      if (WIFEXITED(status)) {
        printf("Exit %d\n", WEXITSTATUS(status));
      }
    }
  }
}
