/*
 * 引用: head first c
 * 第4章 複数のソースファイルの使用 2
*/

#include <stdio.h>
#include <limits.h> /* 整数型の値 */
#include <float.h> /* 浮動小数点数型の値 */

int main()
{
  printf("INT_MAXの値は%i\n", INT_MAX);
  printf("INT_MINの値は%i\n", INT_MIN);
  printf("intは%zuバイトを占めます\n", sizeof(int));

  printf("FLT_MAXの値は%f\n", FLT_MAX);
  printf("FLT_MINの値は%.50f\n", FLT_MIN);
  printf("floatは%zバイトを占めます\n", sizeof(float));

  return 0;
}

/*
 * コンピュータのビットサイズ(32ビット、64ビットetc...)
 *   コンピュータが扱える数値の最適なサイズ
 *   基本データ型(int)のサイズはコンピュータのビットサイズに最適化される
*/
