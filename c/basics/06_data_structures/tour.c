/*
 * 引用: head first c
 * 第6章 データ構造と動的メモリ 1
*/

/*
 * 連結リスト
 *   抽象データ構造
 *   リストの途中に要素を挿入することが可能(可変長)
 *   データアクセス時、リストの頭から該当の要素までリンクを辿っていく必要がある
 *     <-> 配列は固定長であり、要素の追加ができない
 *         データアクセス時、インデックスを指定することによって直接アクセスが可能
 *
 *   素早く挿入できるケースでは連結リスト、
 *   要素に直接アクセスしたい場合は配列を選ぶ
 *
 * 再帰構造体
 *  同じ型の別の構造体へのリンク(ポインタ)を含む構造体
*/

#include <stdio.h>

typedef struct island { /* 再帰構造体には名前が必要 */
  char *name;           /* 空港名 */
  char *opens;          /* 開始時間 */
  char *closes;         /* 終了時間 */
  struct island *next;  /* 次の島へのポインタ */
} island;

void display(island *start);

int main()
{
  /* nextフィールドをNULLにすることによってポインタを0に設定 */
  island amity = { "アミティ", "9:00", "17:00", NULL };
  island craggy = { "クラッギー", "9:00", "17:00", NULL };
  island isla_nublar = { "イスラヌブラル", "9:00", "17:00", NULL };
  island shutter = { "シャッター", "9:00", "17:00", NULL };

  amity.next = &craggy;        /* アミティ島にクラッギー島へのポインタを設定 */
  craggy.next = &isla_nublar;  /* クラッギー島にイスラヌブラル島へのポインタを設定 */
  isla_nublar.next = &shutter; /* イスラヌブラル島にシャッター島へのポインタを設定 */


  /* イスラヌブラル島とシャッター島の間にスカル島を追加する */
  island skull = { "スカル", "9:00", "17:00", NULL };

  isla_nublar.next = &skull; /* イスラヌブラル島にスカル島へのポインタを設定 */
  skull.next = &shutter;     /* スカル島にシャッター島へのポインタを設定 */

  display(&amity); /* 連結リストの最初の要素のポインタを渡す */

  return 0;
}

void display(island *start)
{
  island *i = start;

  /*
   * 次の島がnext値を持たなくなるまでループを続ける
   * ループの最後に次の島へ移る
   */
  for(; i != NULL; i = i->next) {
    printf("名前: %s 営業時間: %s-%s\n", i->name, i->opens, i->closes);
  }
}
