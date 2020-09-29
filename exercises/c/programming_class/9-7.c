// 参照: 例解UNIX/Linuxプログラミング教室P340

#include <signal.h>
#include <stdio.h>
#include <unistd.h>

void handler(int sig)
{
}

void my_sleep(int seconds)
{
  signal(SIGALRM, handler);
  alarm(seconds);
  pause();
}

int main()
{
  printf("Hello\n");
  my_sleep(3);
  printf("Bye\n");

  return 0;
}
