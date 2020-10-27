// 例解UNIX/Linuxプログラミング教室 P73

#include <stdio.h>

int main()
{
  char c;
  char *p = &c;
  *p = 'a';
  printf("%c\n", *p);
}
