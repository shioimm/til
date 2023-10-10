// 新・標準プログラマーズライブラリ C言語 ポインタ完全制覇 P234

#include <stdio.h>

void func(int *x, double *y)
{
  *x = 5;
  *y = 3.5;
}

int main(void)
{
  int    x;
  double y;

  func(&x, &y);
  printf("x.. %d, y.. %f\n", x, y);

  return 0;
}
// x.. 5, y.. 3.500000
