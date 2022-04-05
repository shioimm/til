// 詳説Cポインタ P28

#include <stdio.h>

int main(void)
{
  int        x = 5;
  const int  y = 500; // 再代入不可
  int       *px;
  const int *py; // 定数へのポインタ

  px = &x;
  py = &y; // ポインタは再代入可能、ポインタの指す値は再代入不可

  printf("x..  %d (%p)\n", x,  &x);
  printf("y..  %d (%p)\n", y,  &y);
  printf("px.. %p (%p)\n", px, &px);
  printf("py.. %p (%p)\n", py, &py);

  return 0;
}
