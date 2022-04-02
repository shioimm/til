// 新・標準プログラマーズライブラリ C言語 ポインタ完全制覇 P61

#include <stdio.h>

void get_xy(double *x, double *y)
{
  printf("(get_xy) x..   %f, y..   %f\n", *x, *y);
  printf("(get_xy) &x..  %p, &y..  %p\n", (void*)x, (void*)y);
  printf("(get_xy) &xp.. %p, &yp.. %p\n", (void*)&x, (void*)&y);
  puts("// *x = 1.0;");
  puts("// *y = 2.0;");
  *x = 1.0;
  *y = 2.0;
}

int main(void)
{
  double x = 10.0;
  double y = 20.0;

  printf("(main)   x..   %f, y..   %f\n", x, y);
  printf("(main)   &x..  %p, &y..  %p\n", (void*)&x, (void*)&y);

  puts("---");
  puts("// get_xy(&x, &y);");
  get_xy(&x, &y);
  puts("---");

  printf("(main)   x..   %f, y..   %f\n", x, y);

  return 0;
}

// (main)   x..   10.000000, y..   20.000000
// (main)   &x..  0x7ffee4899750, &y..  0x7ffee4899748
// ---
// // get_xy(&x, &y);
// (get_xy) x..   10.000000, y..   20.000000
// (get_xy) &x..  0x7ffee4899750, &y..  0x7ffee4899748
// (get_xy) &xp.. 0x7ffee4899718, &yp.. 0x7ffee4899710
// // *x = 1.0;
// // *y = 2.0;
// ---
// (main)   x..   1.000000, y..   2.000000
