// 参照: 例解UNIX/Linuxプログラミング教室P347

#include <signal.h>

int main()
{
  sigset_t sigset;
  sigemptyset(&sigset);
  sigaddset(&sigset, SIGINT);
  sigaddset(&sigset, SIGTERM);

  return 0;
}
