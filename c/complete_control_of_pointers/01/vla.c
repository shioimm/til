/*
 * 新・標準プログラマーズライブラリ C言語 ポインタ完全制覇
 * 第1章 まずは基礎から 予備知識と復習 7
*/

/*
 * - 可変長配列
 * - 動的配列(malloc())
*/
#include <stdio.h>

int main()
{
  int size1, size2, size3;

  printf("Enter any of 3 integers.\n");
  scanf("%d%d%d", &size1, &size2, &size3);

  /* 可変長配列の宣言 */
  int array1[size1];
  int array2[size2][size3];

  int i;
  for (i = 0; i < size1; i++) {
    array1[i] = i;
  }

  int j;
  for (i = 0; i < size2; i++) {
    for (j = 0; j < size3; j++) {
      array2[i][j] = i * size3 + j;
    }
  }

  for (i = 0; i < size1; i++) {
    printf("array1[%d]..%d\n", i, array1[i]);
  }

  for (i = 0; i < size2; i++) {
    for (j = 0; j < size3; j++) {
      printf("\t%d", array2[i][j]);
    }
    printf("\n");
  }

  printf("sizeof(array1)..%zd\n", sizeof(array1));
  printf("sizeof(array2)..%zd\n", sizeof(array2));

  return 0;
}

/*
 * Enter any of 3 integers.
 * 1
 * 2
 * 3
 * array1[0]..0
 *  0 1 2
 *  3 4 5
 * sizeof(array1)..4
 * sizeof(array2)..24
*/
