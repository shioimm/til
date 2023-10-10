// 参照: 例解UNIX/Linuxプログラミング教室P333

#include <signal.h>

int main()
{
  signal(SIGINT, SIG_IGN);

  while(1);
}
