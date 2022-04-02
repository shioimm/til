// 新・標準プログラマーズライブラリ C言語 ポインタ完全制覇
#include <stdio.h>

int main(void)
{
  int array[5];
  int *p;
  int i;

  for (i = 0; i < 5; i++) {
    printf("array[%d] = %d\n", i, i);
    array[i] = i;
  }

  // int *p;
  // for (p = &array[0]; p != &array[5]; p++)
  //   printf("array[%d](%p).. %d\n", *p, p, *p);
  // }

  p = array; // p = &array[0]; と同じ (配列はその先頭要素へのポインタに読み替えられる)

  for (i = 0; i < 5; i++) {
    printf("array[%d](%p).. %d\n", i, (p + i), p[i]); // p[i]は*(p + i)のシンタックスシュガー
  }

  return 0;
}

// array[0] = 0
// array[1] = 1
// array[2] = 2
// array[3] = 3
// array[4] = 4
// array[0](0x7ffeef3e8740).. 0
// array[1](0x7ffeef3e8744).. 1
// array[2](0x7ffeef3e8748).. 2
// array[3](0x7ffeef3e874c).. 3
// array[4](0x7ffeef3e8750).. 4
