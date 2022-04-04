// 新・標準プログラマーズライブラリ C言語 ポインタ完全制覇 P238

#include <stdio.h>
#include <stdlib.h>

int main(void)
{
  int  *variable_array = NULL;
  int  size = 3;
  char buf[256];
  int  i;

  variable_array = realloc(variable_array, sizeof(int) * size);

  for (i = 0; i < size; i++) {
    printf("variable_array[%d].. %d\n", i, variable_array[i]);
  }

  return 0;
}

// variable_array[0].. 0
// variable_array[1].. 0
// variable_array[2].. 0
