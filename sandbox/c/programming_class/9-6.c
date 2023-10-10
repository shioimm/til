// 参照: 例解UNIX/Linuxプログラミング教室P339

#include <signal.h>

int main()
{
  raise(SIGINT);

  return 0;
}
