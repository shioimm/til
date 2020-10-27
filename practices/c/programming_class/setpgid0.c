// 参照: 例解UNIX/Linuxプログラミング教室P366

#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>

int main()
{
  pid_t pid = fork();
  int c     = (pid == 0 ? '.' : '@');

  while (1) {
    fprintf(stderr, "%c", c);
    sleep(1);
  }
}
