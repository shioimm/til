// 参照: 例解UNIX/Linuxプログラミング教室P347

#include <signal.h>

int main()
{
  sigset_t sigset;
  sigemptyset(&sigset);
  sigfillset(&sigset);
  sigdelset(&sigset, SIGINT);
  sigdelset(&sigset, SIGQUIT);

  return 0;
}
