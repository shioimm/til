// 例解UNIX/Linuxプログラミング教室 P89

#include <stdio.h>

int L2B_int(int little)
{
  int big;

  char *lc = (char *)&little;
  char *bc = (char *)&big;

  for (int i = 0; i < sizeof(little); i++) {
    bc[sizeof(little) - i - 1] = lc[i];
  }

  return big;
}

int main()
{
  int x = 0x12345678;
  printf("%x -> %x\n", x, L2B_int(x));

  return 0;
}
