// 参照: 例解UNIX/Linuxプログラミング教室P278

#include <stdio.h>
#include <sys/types.h> // fork, read, wait, write
#include <sys/uio.h>   // read, write
#include <sys/wait.h>  // wait
#include <unistd.h>    // close, fork, pipe, read, write

enum {
  SIZE = 1024 * 1024,
};

int main()
{
  int n, fd[2];
  char buf[SIZE], buf2[SIZE] = "Hello\n";
  pid_t pid;

  pipe(fd);

  if ((pid = fork()) == 0) {
    close(fd[1]);
    while((n = read(fd[0], buf, sizeof(buf))) > 0) {
      printf("%6sn = %d\n", buf, n);
    }
    close(fd[0]);
  } else {
    close(fd[0]);
    write(fd[1], buf2, sizeof(buf2));
    close(fd[1]);
    wait(NULL);
  }
}
