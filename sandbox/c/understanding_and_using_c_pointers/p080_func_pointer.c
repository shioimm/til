// 詳説Cポインタ P80

#include <stdio.h>

int add(int x, int y)
{
  return x + y;
}

int sub(int x, int y)
{
  return x - y;
}

typedef int (*Operation)(int, int);

int compute(Operation op, int x, int y)
{
  return op(x, y);
}

int main(void)
{
  printf("%d\n", compute(add, 5, 6));
  printf("%d\n", compute(sub, 5, 6));

  return 0;
}
