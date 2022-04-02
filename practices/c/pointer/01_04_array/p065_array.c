// 新・標準プログラマーズライブラリ C言語 ポインタ完全制覇 P65
#include <stdio.h>

int main(void)
{
  int array[5];
  int i;

  for (i = 0; i < 5; i++) {
    array[i] = i;
    printf(" array[%d].. %d\n", i, array[i]);
    printf("&array[%d].. %p\n", i, (void*)&array[i]);
  }

  return 0;
}

//  array[0].. 0
// &array[0].. 0x7ffee829e750
//  array[1].. 1
// &array[1].. 0x7ffee829e754
//  array[2].. 2
// &array[2].. 0x7ffee829e758
//  array[3].. 3
// &array[3].. 0x7ffee829e75c
//  array[4].. 4
// &array[4].. 0x7ffee829e760
