// 参照: 例解UNIX/Linuxプログラミング教室P339

#include <signal.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
  pid_t pid = atoi(argv[1]);

  kill(pid, SIGTERM);

  return 0;
}
