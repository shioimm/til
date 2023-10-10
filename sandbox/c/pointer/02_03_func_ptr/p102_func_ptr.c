// 新・標準プログラマーズライブラリ C言語 ポインタ完全制覇 P102
#include <stdio.h>

void func1(double d)
{
  printf("(func1) d + 1.0 = %f\n", d + 1.0);
}

void func2(double d)
{
  printf("(func2) d + 2.0 = %f\n", d + 2.0);
}

int main(void)
{
  void (*func_p)(double); // 関数ポインタ

  puts("// void (*func_p)(double);");
  puts("// func_p = func1;");
  func_p = func1;
  func_p(1.0);

  puts("// func_p = func2;");
  func_p = func2;
  func_p(1.0);

  return 0;
}

// // void (*func_p)(double);
// // func_p = func1;
// (func1) d + 1.0 = 2.000000
// // func_p = func2;
// (func2) d + 2.0 = 3.000000
