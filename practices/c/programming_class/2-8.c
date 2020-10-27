// 例解UNIX/Linuxプログラミング教室 P85

#include <stdio.h>

int main()
{
  char buf[1024];
  printf("name: \n");
  fgets(buf, sizeof(buf), stdin);
  printf("hello %s\n", buf);

  return 0;
}
