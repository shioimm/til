// 参照: 例解UNIX/Linuxプログラミング教室P333

#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

void loop()
{
  int i;
  for (i = 0; i < 0xFFFFF; i++);
}

void handler(int sig)
{
  printf("Hello\n");
  exit(0);
}

int main()
{
  signal(SIGALRM, handler);
  alarm(3);

  while (1) {
    loop();
    fprintf(stderr, ".");
  }
}
