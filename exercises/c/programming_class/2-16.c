// 例解UNIX/Linuxプログラミング教室 P99

#include <stdio.h>

int check_bit(unsigned int x, int n)
{
  return (x & (1 << n)) != 0;
}

int main()
{
  for (int i = 0; i < 31; i++) {
    printf("%d\n", check_bit(0x20, i));
  }

  return 0;
}
