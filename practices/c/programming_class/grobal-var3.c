// 参照: 例解UNIX/Linuxプログラミング教室P357

#include <signal.h>
#include <stdio.h>
#define MAX 100000000

static volatile long long counter1 = 0, counter2 = 0;

void handler(int sig)
{
  counter1++;
  counter2++;
}

int main()
{
  long long i;
  sigset_t set, oset;

  signal(SIGINT, handler);
  sigemptyset(&set);
  sigaddset(&set, SIGINT);

  for (i = 0; i < MAX; i++) {
    sigprocmask(SIG_BLOCK, &set, &oset);
    counter1++;
    sigprocmask(SIG_SETMASK, &oset, NULL);
  }

  sigprocmask(SIG_BLOCK, &set, &oset);

  printf("counter1 is %lld", counter1);
  printf("counter2 is %lld", counter2);

  sigprocmask(SIG_SETMASK, &oset, NULL);

  return 0;
}
