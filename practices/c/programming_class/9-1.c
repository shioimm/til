// 参照: 例解UNIX/Linuxプログラミング教室P332

#include <signal.h>
#include <stdio.h>
#include <stdlib.h>

void handler(int sig)
{
  puts("Hello\n");
  exit(1);
}

int main()
{
  signal(SIGINT, handler);

  while(1);
}
