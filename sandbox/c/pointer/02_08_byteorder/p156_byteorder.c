// 新・標準プログラマーズライブラリ C言語 ポインタ完全制覇 P156

#include <stdio.h>

int main(void)
{
  puts("// int            foo   = 0x12345678;");
  puts("// unsigned char *foo_p = (unsigned char*)&foo;");

  int            foo   = 0x12345678;
  unsigned char *foo_p = (unsigned char*)&foo;

  printf("foo_p[0].. %x\n", foo_p[0]);
  printf("foo_p[1].. %x\n", foo_p[1]);
  printf("foo_p[2].. %x\n", foo_p[2]);
  printf("foo_p[3].. %x\n", foo_p[3]);

  return 0;
}

// // int            foo   = 0x12345678;
// // unsigned char *foo_p = (unsigned char*)&foo;
// foo_p[0].. 78
// foo_p[1].. 56
// foo_p[2].. 34
// foo_p[3].. 12 .. リトルエンディアン
