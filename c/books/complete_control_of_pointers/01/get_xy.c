/*
 * 新・標準プログラマーズライブラリ C言語 ポインタ完全制覇
 * 第1章 まずは基礎から 予備知識と復習 3
*/

#include<stdio.h>

void get_xy(double*x_p, double*y_p)
{
  printf("x_p..%p, y_p..%p\n", (void*)x_p, (void*)y_p);
  printf("&x_p..%p, &y_p..%p\n", (void*)&x_p, (void*)&y_p);

  *x_p = 1.0;
  *y_p = 2.0;
}

int main()
{
  double x;
  double y;

  printf("&x..%p, &y..%p\n", (void*)&x, (void*)&y);

  get_xy(&x, &y);

  printf("x..%f, y..%f\n", x, y);

  return 0;
}
/*
 * &x   0x7ffee46167f0 / &y   0x7ffee46167e8
 * x_p  0x7ffee46167f0 / y_p  0x7ffee46167e8
 * &x_p 0x7ffee46167c8 / &y_p 0x7ffee46167c0
 * x..1 000000         / y    2.000000
*/
