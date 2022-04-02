// 新・標準プログラマーズライブラリ C言語 ポインタ完全制覇 P108

#include <stdio.h>

void func(int a, int b)
{
  int c, d;

  printf("(func) &c.. %p. &d.. %p\n", (void*)&c, (void*)&d);
  printf("(func) &a.. %p, &b.. %p\n", (void*)&a, (void*)&b);
}

int main(void)
{
  int a, b;

  func(1, 2);
  printf("(main) &a.. %p, &b.. %p\n", (void*)&a, (void*)&b);

  return 0;
}

// (func) &c.. 0x7ffeeb8e3724. &d.. 0x7ffeeb8e3720
// (func) &a.. 0x7ffeeb8e372c, &b.. 0x7ffeeb8e3728
// (main) &a.. 0x7ffeeb8e3748, &b.. 0x7ffeeb8e3744
