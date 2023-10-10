// 参照: 例解UNIX/Linuxプログラミング教室P331

#include <signal.h>
#include <stdio.h>
#include <unistd.h>

void handler(int sig)
{
  fprintf(stderr, "@");
}

int main()
{
  signal(SIGINT, handler);

  while (1) {
    sleep(1);
    fprintf(stderr, ".");
  }

  return 0;
}
