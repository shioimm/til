// 参照: 例解UNIX/Linuxプログラミング教室P205

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(int argc, char *argv[])
{
  if (argc <= 2) {
    fprintf(stderr, "usage: %s <directory> <command> ...\n", argv[0]);
  }

  if (chdir(argv[1]) == -1) {
    perror("chdir");
    exit(1);
  }

  execvp(argv[2], &argv[2]);

  perror("exec");
  exit(1);
}
