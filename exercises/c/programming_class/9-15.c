// 参照: 例解UNIX/Linuxプログラミング教室P360

#include <signal.h>
#include <stdio.h>

int SIGINT_is_blocked()
{
  sigset_t old_sigset;
  sigprocmask(SIG_SETMASK, NULL, &old_sigset);
  return sigismember(&old_sigset, SIGINT);
}

int main()
{
  sigset_t sigset;
  sigemptyset(&sigset);
  sigaddset(&sigset, SIGINT);

  printf("%d\n", SIGINT_is_blocked());

  sigprocmask(SIG_BLOCK, &sigset, NULL);

  printf("%d\n", SIGINT_is_blocked());

  sigprocmask(SIG_UNBLOCK, &sigset, NULL);

  printf("%d\n", SIGINT_is_blocked());

  return 0;
}
