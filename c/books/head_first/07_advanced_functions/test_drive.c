/*
 * 引用: head first c
 * 第7章 高度な関数 2
*/

/*
 * コンパレータ関数
 *   等価性を検証する関数全般
 *   (あるデータと別のデータと比較したときに同じ、大きい、小さい)
 *
 * qsort()関数
 *   標準ライブラリ
 *   コンパレータ関数へのポインタを引数にとる高階関数
 *   実際の配列を操作してソートする(配列のコピーは作られない)
 *   qsort(void *array,      配列へのポインタ
 *         size_t length,    配列の長さ
 *         size_t item_size, 配列の各要素のサイズ
 *         int (*compar)(const void *, const void *)); 配列の二つの要素を比較する関数へのポインタ
 *
 * void*ポインタ
 *   あらゆる種類のデータのアドレスを格納する
 *   利用する前に具体的な型にキャストする
*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/* コンパレータ関数 */
int compare_scores(const void* score_a, const void* score_b)
int compare_scores_desc(const void* score_a, const void* score_b)
int compare_areas(const void* a, const void* b)
int compare_names(const void* a, const void* b)

/* 値a・bを比較し、aが大きい場合正の数値、小さい場合負の数値、等しい場合0を返す */
int compare_scores(const void* score_a, const void* score_b) /* あらゆる型のポインタを引数に取る*/
{
  /* voidポインタをint型にキャスト */
  int a = *(int*)score_a; /* アドレスscore_aに格納されている値を取得 */
  int b = *(int*)score_b; /* アドレスscore_bに格納されている値を取得 */

  return a - b;
}

/* compare_scoresに逆の値を渡す */
int compare_scores_desc(const void* score_a, const void* score_b)
{
  return compare_scores(score_b, score_a);
  /* -compare_scores(score_a, score_b)でも良い */
}

typedef struct {
  int width;
  int height;
} rectangle;

/* rectangle型にキャストした値a・bを比較し、aが大きい場合正の数値、小さい場合負の数値、等しい場合0を返す */
int compare_areas(const void* a, const void* b)
{
  /* voidポインタをrectangle型にキャスト */
  rectangle* ra = (rectangle*)a; /* アドレスaに格納されている値を取得 */
  rectangle* rb = (rectangle*)b; /* アドレスbに格納されている値を取得 */

  int area_a = ra->width * ra->height;
  int area_b = rb->width * rb->height;

  return area_a - area_b;
}

/* 文字へのポインタから文字列にキャストし、strcmpで文字列a, bを比較する */
int compare_names(const void* a, const void* b)
{
  /* 文字列配列の各項目であるcharポインタ(char*)へのポインタにキャスト */
  char** sa = (char**)a; /* アドレスaに格納されている値を取得 */
  char** sb = (char**)b; /* アドレスbに格納されている値を取得 */
  /* 同じ型(charポインタへのポインタ変数)sa、sbに格納 */

  return strcmp(*sa, *sb);
  /*
   * saとsbはchar**型であるため、
   * ポインタ変数の通常変数モードで文字列の実際の値を取得し、
   * strcmp()関数に渡す
  */
}

int main()
{
  int scores[] = { 543, 323, 32, 554, 11, 3, 112 };
  int i;

  qsort(scores, 7, sizeof(int), compare_scores_desc);

  puts("順番に並べた点数: ");

  for (i = 0; i < 7; i++) {
    printf("点数 = %i\n", scores[i]);
  }

  char *names[] = { "Karen", "Mark", "Brett", "Molly" };
  qsort(names, 4, sizeof(char*), compare_names);
  puts("順番に並べた名前: ");

  for (i = 0; i < 4; i++) {
    printf("%s\n", names[i]);
  }

  return 0;
}
