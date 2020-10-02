// 参照: 例解UNIX/Linuxプログラミング教室P357

#include <signal.h>
#include <stdio.h>
#define MAX 100000000

static volatile long long counter = 0;

void handler(int sig)
{
  printf("%lld\n", counter);
}

int main()
{
  long long i;
  signal(SIGINT, handler);

  for (i = 0; i < MAX; i++) {
    counter++;
  }

  printf("counter is %lld", counter);

  return 0;
}
