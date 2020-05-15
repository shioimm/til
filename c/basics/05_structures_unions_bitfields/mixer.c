/*
 * 引用: head first c
 * 第5章 構造体、共用体、ビットフィールド 6
*/

/*
 * 共用体(union型)
 *   複数のフィールドに対して1つだけメモリ空間を割り当てる
 *   各フィールドに異なる型が割り当てられた場合、容量の大きい方のメモリ空間が割り当てられる
 *
 *   typedef union { <- floatまたはshortのメモリ空間(大きい方)が割り当てられる
 *     short count;  <- 各フィールドは同じメモリ空間に格納される
 *     float weight;
 *     float volume:
 *   } quantity;
 *
 *   union変数を宣言する
 *     C89形式
 *       quantity q = { 4 }:
 *     指示付き初期化子
 *       quantity q = { .weight = 4 };
 *     ドット表記
 *       quantity q:
 *       q.volume = 3.7;
*/

#include <stdio.h>

typedef union {
  float lemon;
  int lime_pieces;
} lemon_lime;

typedef struct {
  float tequila;
  float cointreau;
  lemon_lime citrus;
} margarita;

int main()
{
  /*
  / * 宣言と同じ行でunionへ代入を行うことができる
  / * (宣言と別の行で代入を行うと、第三要素は配列とみなされる)

  / * 2.0単位のテキーラ\n1.0単位のコアントロー\2.0単位のジュース\n
  / *   margarita m = { 2.0, 1.0, { 2 } };
  / *   printf("%2.1f単位のテキーラ\n%2.1f単位のコアントロー\n%2.1f単位のジュース\n",
  / *          m.tequila, m.cointreau, m.citrus.lemon);

  / * 2.0単位のテキーラ\n1.0単位のコアントロー\n0.5単位のジュース\n
  / *   margarita m = { 2.0, 1.0, { 0.5 } };
  / *   printf("%2.1f単位のテキーラ\n%2.1f単位のコアントロー\n%2.1f単位のジュース\n",
  / *          m.tequila, m.cointreau, m.citrus.lemon);

  / * 2.0単位のテキーラ\n1.0単位のコアントロー\n1切れのライム\n
  / *   margarita m = { 2.0, 1.0, { .lime_pieces=1 } };
  / *   printf("%2.1f単位のテキーラ\n%2.1f単位のコアントロー\n%i切れのライム\n",
  / *          m.tequila, m.cointreau, m.citrus.lime_pieces);
  */

  return 0;
}
