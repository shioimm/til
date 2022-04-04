// 新・標準プログラマーズライブラリ C言語 ポインタ完全制覇 P237

#include <stdio.h>
#include <stdlib.h>

int main(void)
{
  char buf[256];
  int  size = 3;
  int  *variable_array;
  int  i;

  variable_array = malloc(sizeof(int) * size);

  for (i = 0; i < size; i++) {
      variable_array[i] = i;
      printf("variable_array[%d].. %d\n", i, variable_array[i]);
  }

  return 0;
}

// variable_array[0].. 0
// variable_array[1].. 1
// variable_array[2].. 2
