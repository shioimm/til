// 参照: 例解UNIX/Linuxプログラミング教室P279

#include <stdio.h>
#include <sys/types.h> // fork
#include <unistd.h>    // close, dup2, fork, pipe

int main(int argc, char *argv[])
{
  int fd[2];
  pid_t pid;

  if (argc < 3) {
    fprintf(stderr, "%s command1 command2\n", argv[0]);
  }

  pipe(fd);

  if ((pid = fork()) == 0) {
    dup2(fd[1], 1);
    close(fd[0]);
    close(fd[0]);
    execlp(argv[1], argv[1], (char*)NULL);
  }

  dup2(fd[0], 0);
  close(fd[0]);
  close(fd[1]);
  execlp(argv[2], argv[2], (char*)NULL);
}
