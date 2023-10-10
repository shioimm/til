#include <stdio.h>

int main(void)
{
  // 配列の先頭要素へのポインタの配列
  char *colors1[] = {
    "red",
    "green",
    "blue",
  };

  printf("%c\n", colors1[0][0]); // r
  printf("%c\n", colors1[1][0]); // g
  printf("%c\n", colors1[2][0]); // b

  // char配列の配列 (メモリ上に連続して格納される)
  char colors2[][6] = {
    "red",
    "green",
    "blue",
  };

  printf("%c\n", colors2[0][0]); // r
  printf("%c\n", colors2[1][0]); // g
  printf("%c\n", colors2[2][0]); // b

  return 0;
}
