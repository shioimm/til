// 新・標準プログラマーズライブラリ C言語 ポインタ完全制覇 P133

#include <stdio.h>

void sub(int size1, int size2, int size3)
{
  puts("// int var1;");
  puts("// int var2;");
  puts("// int var3;");
  printf("// int array1[%d];\n", size1);
  printf("// int array2[%d][%d];\n", size2, size3);
  int var1;
  int var2;
  int var3;
  int array1[size1];
  int array2[size2][size3];

  printf("array1.. %p\n", (void*)array1);
  printf("array2.. %p\n", (void*)array2);
  printf("&var1..  %p\n", (void*)&var1);
  printf("&var2..  %p\n", (void*)&var2);
  printf("&var3..  %p\n", (void*)&var3);
}

int main(void)
{
  int size1, size2, size3;
  scanf("%d%d%d", &size1, &size2, &size3);

  sub(size1, size2, size3);
}

// // int var1;
// // int var2;
// // int var3;
// // int array1[1];
// // int array2[2][3];
// array1.. 0x7ffee15b96b0
// array2.. 0x7ffee15b9690
// &var1..  0x7ffee15b9738
// &var2..  0x7ffee15b9734
// &var3..  0x7ffee15b9730
