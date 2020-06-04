/*
 * 新・標準プログラマーズライブラリ C言語 ポインタ完全制覇
 * 第2章 実験してみよう Cはメモリをどう使うのか 3
*/

#include<stdio.h>

void func1(double d)
{
  printf("func1: d + 1.0 = %f\n", d + 1.0);
}

void func2(double d)
{
  printf("func2: d + 2.0 = %f\n", d + 2.0);
}

int main()
{
  void (*func_p)(double);

  func_p = func1;
  func_p(1.0);

  func_p = func2;
  func_p(1.0);

  return 0;
}

/*
 * func1: d + 1.0 = 2.000000
 * func2: d + 2.0 = 3.000000
* /
