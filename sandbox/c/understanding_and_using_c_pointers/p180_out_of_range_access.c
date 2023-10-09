// 詳説Cポインタ P180
#include <stdio.h>

int main()
{
  char foo[8] = "1234567\0";
  char bar[8] = "1234567\0";
  char buz[8] = "1234567\0";

  printf("%p: %s\n", &foo, foo);
  printf("%p: %s\n", &bar, bar);
  printf("%p: %s\n", &buz, buz);

  bar[-2] = 'X';
  bar[0] = 'X';
  bar[10] = 'X';

  printf("%p: %s\n", &foo, foo);
  printf("%p: %s\n", &bar, bar);
  printf("%p: %s\n", &buz, buz);

  return 0;
}
