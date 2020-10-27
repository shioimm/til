// 参照: 例解UNIX/Linuxプログラミング教室P223

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h> // fork, getpid, getppid
#include <unistd.h>    // fork, getpid, getppid, sleep

int main()
{
  if (fork() == 0) {
    sleep(3);
    printf("\nmy parent is now pid %d\n", getppid());
    exit(0);
  }

  printf("parent process, pid %d\n", getpid());
  exit(0);
}
