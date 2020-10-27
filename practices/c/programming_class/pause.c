// 参照: 例解UNIX/Linuxプログラミング教室P336

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
  pause();
  fprintf(stderr, "Hello\n");

  return 0;
}
