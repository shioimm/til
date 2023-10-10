// 参照: 例解UNIX/Linuxプログラミング教室P199

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h> // fork, getpid, getppid
#include <unistd.h> // fork, getpid, getppid, sleep

int main()
{
  pid_t pid;

  if ((pid = fork()) == 0) {
    printf("child: parent PID = %d, my PID = %d\n",
           getppid(),
           getpid());
    exit(0);
  } else {
    printf("parent: my PID = %d, child PID = %d\n",
           getpid(),
           pid);
    for (;;) {
      sleep(1);
    }
  }

  return 0;
}
