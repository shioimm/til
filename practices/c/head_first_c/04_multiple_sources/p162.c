#include <stdio.h>

int main(void)
{
  printf("char:        %zu\n", sizeof(char));
  printf("short:       %zu\n", sizeof(short));
  printf("int:         %zu\n", sizeof(int));
  printf("long:        %zu\n", sizeof(long));
  printf("float:       %zu\n", sizeof(float));
  printf("double:      %zu\n", sizeof(double));
  printf("long double: %zu\n", sizeof(long double));

  return 0;
}

// char:        1
// short:       2
// int:         4
// long:        8
// float:       4
// double:      8
// long double: 16

// unsigned - 数値を正の値として扱う unsignedがつかない数値よりも1ビット分大きな値を格納できる
// long     - 大きな範囲の数値を格納する
