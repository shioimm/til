// 例解UNIX/Linuxプログラミング教室 P74

#include <stdio.h>
#include <stdlib.h>

char *itoa(int i)
{
  static char buf[1024];
  snprintf(buf, sizeof(buf), "%d", i);

  return buf;
}

int main()
{
  char *p = itoa(1234);
  printf("p=%s\n", p);
}
