// 新・標準プログラマーズライブラリ C言語 ポインタ完全制覇 P38

#include <stdio.h>

int main(void)
{
  // 各型のサイズ
  printf("_Bool..      %d byte\n", (int)sizeof(_Bool));
  printf("char..       %d byte\n", (int)sizeof(char));
  printf("short..      %d byte\n", (int)sizeof(short));
  printf("int..        %d byte\n", (int)sizeof(int));
  printf("long..       %d byte\n", (int)sizeof(long));
  printf("long long .. %d byte\n", (int)sizeof(long long));
  printf("float ..     %d byte\n", (int)sizeof(float));
  printf("double ..    %d byte\n", (int)sizeof(double));

  // _Bool..      1 byte
  // char..       1 byte
  // short..      2 byte
  // int..        4 byte
  // long..       8 byte
  // long long .. 8 byte
  // float ..     4 byte
  // double ..    8 byte
}
