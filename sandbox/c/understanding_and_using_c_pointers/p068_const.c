// 詳説Cポインタ P68

#include <stdio.h>

void cp(const int* x, int *y)
{
  // *x = *y; はxの参照先がread onlyなので不可
  *y = *x;
}

int main(void)
{
  const int x = 100;
  int y = 5;

  cp(&x, &y);

  printf("x.. %d, y.. %d\n", x, y);

  return 0;
}
