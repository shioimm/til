/*
 * 引用: head first c
 * 第4章 複数のソースファイルの使用
*/

/*
 * データ型
 *   char   文字を文字コード(数値)として格納
 *   int    整数を格納し、最低15bitのメモリを占有
 *   short  整数を格納し、intの約半分のメモリを占有
 *   long   整数を格納し、intの約2倍のメモリを占有
 *   float  浮動小数点数を格納
 *   double 浮動小数点数を格納し、floatの約2倍のメモリを占有
 * 桁数が溢れた場合、溢れた分が無視される -> 数値が変わる
 *
 * 整数を浮動小数点数にキャスト
 *   float x =  (float)7 / 3;
 *   printf("%f\n", x);
*/

/* ライブラリコードの保存されたディレクトリにあるファイルは<>でインクルードする */
#include <stdio.h>
/* 関数シグネチャを定義するヘッダファイルをローカルからインクルード */
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
    /* 浮動小数点数を小数点以下2桁にフォーマット */
    printf("ここまでの合計: %.2f\n", add_with_tax(val));
    printf("品目の値段: ");
  }

  printf("\n最終合計: %.2f\n", total);
  printf("品目数: %hi\n", count);
  return 0;
}
