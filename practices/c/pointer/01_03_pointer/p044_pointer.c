// 新・標準プログラマーズライブラリ C言語 ポインタ完全制覇 P44

#include <stdio.h>
int main(void)

{
  int foo = 5;
  int bar = 10;
  int *foo_p;

  puts("// int foo = 5;");
  puts("// int bar = 10;");
  puts("// int *foo_p;");
  printf("&foo..   %p\n", (void*)&foo);
  printf("&bar..   %p\n", (void*)&bar);
  printf("&foo_p.. %p\n", (void*)&foo_p);

  puts("---");

  foo_p = &foo;
  puts("// foo_p = &foo;");
  printf("foo_p..  %p\n", (void*)foo_p);
  printf("*foo_p.. %d\n", *foo_p);

  puts("---");

  *foo_p = 10;
  puts("// *foo_p = 10;");
  printf("foo..    %d\n", foo);

  return 0;
}

// // int foo = 5;
// // int bar = 10;
// // int *foo_p;
// &foo..   0x7ffeed742758
// &bar..   0x7ffeed742754
// &foo_p.. 0x7ffeed742748
// ---
// // foo_p = &foo;
// foo_p..  0x7ffeed742758
// *foo_p.. 5
// ---
// // *foo_p = 10;
// foo..    10
