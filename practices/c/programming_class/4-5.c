// 参照: 例解UNIX/Linuxプログラミング教室P171

#include <stdio.h>

int main()
{
  long long int x = 1234;
  char *s = "Hello";
  printf("%d, %s\n", (int)x, s);

  return 0;
}
