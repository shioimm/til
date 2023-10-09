// 例解UNIX/Linuxプログラミング教室 P75

#include <stdio.h>
#include <string.h>

int main()
{
  char s1[] = "Hello", s2[10];
  strcpy(s2, s1);

  printf("%s\n", s2);
}
