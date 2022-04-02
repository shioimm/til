// 新・標準プログラマーズライブラリ C言語 ポインタ完全制覇 P152

#include <stdio.h>

typedef struct {
  char   char1;
  int    int1;
  char   char2;
  double double1;
  char   char3;
} Foo;

int main(void)
{
  puts("// typedef struct {");
  puts("//   char   char1;");
  puts("//   int    int1;");
  puts("//   char   char2;");
  puts("//   double double1;");
  puts("//   char   char3;");
  puts("// } Foo;");

  Foo foo;

  printf("Foo size.. %d\n", (int)sizeof(Foo));
  printf("foo..      %p\n", (void*)&foo);
  printf("char1..    %p (%i byte)\n", (void*)&foo.char1, (int)sizeof(char));
  printf("int1..     %p (%i byte)\n", (void*)&foo.int1, (int)sizeof(int));
  printf("char2..    %p (%i byte)\n", (void*)&foo.char2, (int)sizeof(char));
  printf("double1..  %p (%i byte)\n", (void*)&foo.double1, (int)sizeof(double));
  printf("char3..    %p (%i byte)\n", (void*)&foo.char3, (int)sizeof(char));

  return 0;
}

// // typedef struct {
// //   char   char1;
// //   int    int1;
// //   char   char2;
// //   double double1;
// //   char   char3;
// // } Foo;
// Foo size.. 32
// foo..      0x7ffee4585738
// char1..    0x7ffee4585738 (1 byte)
// int1..     0x7ffee458573c (4 byte)
// char2..    0x7ffee4585740 (1 byte)
// double1..  0x7ffee4585748 (8 byte)
// char3..    0x7ffee4585750 (1 byte)
