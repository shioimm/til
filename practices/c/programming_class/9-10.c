// 参照: 例解UNIX/Linuxプログラミング教室P348

#include <signal.h>
#include <stdio.h>
#include <stdlib.h>

void handler(int sig)
{
  printf("Hello\n");
  exit(1);
}

int main()
{
  struct sigaction act;
  act.sa_hander = handler;
  act.sa_flags  = SA_RESTART;
  sigemptyset(&act.sa_mask);
  sigaction(SIGINT, &act, NULL);

  while (1);
}
