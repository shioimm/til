// 参照: 例解UNIX/Linuxプログラミング教室P338

#include <sys/types.h> // getpid
#include <signal.h>
#include <stdio.h>
#include <unistd.h>

void handler(int sig)
{
  fprintf(stderr, "handler\n");
}

int main()
{
  signal(SIGINT, handler);
  kill(getpid(), SIGINT);
  raise(SIGINT);

  return 0;
}
