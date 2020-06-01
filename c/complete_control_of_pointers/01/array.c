/*
 * 新・標準プログラマーズライブラリ C言語 ポインタ完全制覇
 * 第1章 まずは基礎から 予備知識と復習 4
*/

/* 配列 -> 同じ型の変数が決まった個数分メモリ上に並んだもの */
#include <stdio.h>

int main()
{
  int array[5];
  int i;

  for (i = 0; i < 5; i++) {
    array[i] = i;
  }

  for (i = 0; i < 5; i++) {
    printf("%d\n", array[i]);
  }

  for (i = 0; i < 5; i++) {
    printf("&array[%d]..%p\n", i, (void*)&array[i]);
  }

  return 0;
}

/*
 * 0
 * 1
 * 2
 * 3
 * 4
 * &array[0] 0x7ffeee28a7f0
 * &array[1] 0x7ffeee28a7f4
 * &array[2] 0x7ffeee28a7f8
 * &array[3] 0x7ffeee28a7fc
 * &array[4] 0x7ffeee28a800
*/
