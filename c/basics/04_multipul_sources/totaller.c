/*
 * 引用: head first c
 * 第4章 複数のソースファイルの使用 1
*/

/*
 * データ型
 *   char   文字を文字コード(数値)として格納(%c)
 *   int    整数を格納し、最低15bitのメモリを占有(%i)
 *   short  整数を格納し、intの約半分のメモリを占有(%hi)
 *   long   整数を格納し、intの約2倍のメモリを占有(%li)
 *   float  浮動小数点数を格納(%f)
 *   double 浮動小数点数を格納し、floatの約2倍のメモリを占有(%lf)
 * 桁数が溢れた場合、溢れた分が無視される -> 数値が変わる
 *
 * 整数を浮動小数点数にキャスト
 *   float x =  (float)7 / 3;
 *   printf("%f\n", x);
 *
 * データ型の正確なサイズはマシンによって異なるため
 * Cにおいては厳密に規定されていない
*/

/* ライブラリコードの保存されたディレクトリにあるファイルは<>でインクルードする */
#include <stdio.h>
/* 関数シグネチャを定義したヘッダファイル"totaller.h"をローカルからインクルード */
#include "totaller.h"

float total = 0.0;
short count = 0;
short tax_percent = 6;

float add_with_tax(float f) /* 返り値を浮動小数点数に指定 */
{
  float tax_rate = 1 + tax_percent / 100.0; /* 整数を不動点小数点へキャスト */
  total = total + (f * tax_rate);
  count = count + 1;

  return total;
}

int main()
{
  float val;
  printf("品目の値段: ");

  while(scanf("%f", &val) == 1) {
    /* %.2f -> 浮動小数点数を小数点以下2桁にフォーマット */
    printf("ここまでの合計: %.2f\n", add_with_tax(val));
    printf("品目の値段: ");
  }

  printf("\n最終合計: %.2f\n", total);
  printf("品目数: %hi\n", count);
  return 0;
}
