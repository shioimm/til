// 新・標準プログラマーズライブラリ C言語 ポインタ完全制覇 P55

#include <stdio.h>

int main(void)
{
  int foo;
  int *foo_p;

  foo_p = &foo;
  printf("foo_p..%p\n", (void*)foo_p);

  foo_p++;
  puts("// foo_p++;");
  printf("foo_p..%p\n", (void*)foo_p);

  return 0;
}

// foo_p..0x7ffeead34748
//
// // foo_p++;
// foo_p..0x7ffeead3474c
