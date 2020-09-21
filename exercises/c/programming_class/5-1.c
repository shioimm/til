// 参照: 例解UNIX/Linuxプログラミング教室P189

#include <stdio.h>
#include <stdlib.h>    // system
#include <sys/types.h> // getpid
#include <unistd.h>    // getpid

int main()
{
  pid_t pid;
  char command[1024];

  pid = getpid();
  printf("pid = %d\n", pid);

  if (snprintf(command, sizeof(command), "ps -l -p %d\n", pid) >= sizeof(command)) {
    fprintf(stderr, "too long command line (pid = %d)\n", pid);
    exit(1);
  }

  system(command);

  return 0;
}
