// 参照: 例解UNIX/Linuxプログラミング教室P367

#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>

int main()
{
  pid_t pid = fork();
  int c     = (pid == 0 ? '.' : '@');

  if (pid == 0) {
    setpgid(getpid(), getpid());
  }

  while (1) {
    fprintf(stderr, "%c", c);
    sleep(1);
  }
}
