// 参照: 例解UNIX/Linuxプログラミング教室P340

#include <signal.h>
#include <stdio.h>
#include <unistd.h>

void handler(int sig)
{
}

void my_sleep(int seconds)
{
  sigset_t new_set, old_set;
  sigemptyset(&new_set);

  sigaddset(&new_set, SIGALRM);
  signal(SIGALRM, handler);

  sigprocmask(SIG_BLOCK, &new_set, &old_set);
  alarm(seconds);

  sigsuspend(&old_set);
  sigprocmask(SIG_SETMASK, &old_set, NULL);
}

int main()
{
  printf("Hello\n");
  my_sleep(3);
  printf("Bye\n");

  return 0;
}
