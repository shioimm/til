// 参照: 例解UNIX/Linuxプログラミング教室P277

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h> // read, write
#include <sys/uio.h>   // read, write
#include <unistd.h>    // close, pipe, read, write

enum {
  SIZE = 1024 * 1024,
};

int main()
{
  int fd[2], nbytes;
  char buf1[SIZE], buf2[SIZE];

  pipe(fd);

  write(fd[1], buf2, sizeof(buf2));
  nbytes = read(fd[0], buf1, sizeof(buf1));

  close(fd[0]);
  close(fd[1]);

  return 0;
}
