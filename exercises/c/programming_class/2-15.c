// 例解UNIX/Linuxプログラミング教室 P95

#include <stdio.h>

int add(int x, int y) { return x + y; }
int sub(int x, int y) { return x - y; }
int mul(int x, int y) { return x * y; }
int mod(int x, int y) { return x / y; }

int (*arith[4])(int, int) = { add, sub, mul, mod };

int main()
{
  printf("%d, %d, %d, %d\n",
         arith[0](20, 10),
         arith[1](20, 10),
         arith[2](20, 10),
         arith[3](20, 10));

  return 0;
}
