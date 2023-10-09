// 新・標準プログラマーズライブラリ C言語 ポインタ完全制覇 P236

#include <stdio.h>

void func(int *array, int size)
{
  int i;

  for (i = 0; i < size; i++) {
    printf("array[%d].. %d\n", i, array[i]);
  }
}

int main(void)
{
  int array[] = { 1, 2, 3, 4, 5 };

  func(array, sizeof(array) / sizeof(array[0]));

  return 0;
}

// array[0].. 1
// array[1].. 2
// array[2].. 3
// array[3].. 4
// array[4].. 5
