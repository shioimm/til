/*
 * 引用: head first c
 * 第6章 データ構造と動的メモリ 2
*/

/*
 * ローカル変数は静的領域であるスタック領域に保存される
 * データの容量が動的に変わる場合、実行時に必要な量の空間を割り当てる必要があるため、
 * 動的記憶領域であるヒープ領域を利用する
 *
 * ヒープ領域
 *   プログラムが長期にわたって使いたいデータを格納する記憶領域
 *   自動的に削除されないため、連結リストの格納に適している
 *
 *   ヒープ領域は、ユーザーが領域の利用終了を通知するまでは領域を確保し続ける
 *   不要になったメモリを解放せずに、さらにメモリを要求するとメモリリークを起こす
 *     <-> スタック領域は関数から戻るたびにローカル記憶領域を解放する
 *
 *   <stdlib.h> malloc()関数(memory allocation)
 *     必要なメモリ量を渡すと、その大きさのメモリを確保するようOSへ依頼する
 *     確保したヒープ領域へのvoid*型(汎用型)のポインタを返す
 *
 *   <stdlib.h> free()関数
 *     malloc()関数で確保したメモリを解放する
 *
 *   <string.h> strdup()関数
 *     文字列の長さを求め、malloc()関数を呼び出してヒープに正しい数の文字を割り当てる
 *     それぞれの文字はヒープの新しい空間にコピーされる
 *     コピーされた文字列へのポインタを返す
*/

/* malloc()関数は確保したメモリの開始アドレスを含むポインタ(void*型の汎用ポインタ)を返す*/

#include <stdio.h>
#include <stdlib.h> /* malloc()関数とfree()関数が含まれる */
#include <string.h> /* strdup()関数が含まれる */

typedef struct island {
  char *name;
  char *opens;
  char *closes;
  struct island *next;
} island;

void display(island *start)
{
  island *i = start;

  for(; i != NULL; i = i->next) {
    printf("名前: %s 営業時間: %s-%s\n", i->name, i->opens, i->closes);
  }
}

/* island構造体のテンプレートを作成する関数を定義 */
/* この関数においてはisland構造体用のメモリとname文字列用のメモリをそれぞれ確保する必要がある */
island* create(char *name) /* 引数 -> name文字列のポインタ / 返り値 -> island構造体のポインタ*/
{
  island *i = malloc(sizeof(island));
  /* island *i =    -> 確保したメモリのアドレスを変数iに格納 */
  /* malloc()       -> 十分なメモリ空間をヒープに確保 */
  /* sizeof(island) -> island構造体が占有するバイト数 */

  /* 新しい構造体のフィールドを設定 */
  i->name = strdup(name);
    /* 渡された文字列をコピーしてヒープへ新たにメモリ空間を確保し、ポインタを保持する */

  i->opens = "9:00";
  i->closes = "17:00";
  /* 文字列リテラルは定数であるためstrdup()関数でのメモリ確保は不要 */

  i->next = NULL;

  return i; /* 新しい構造体のアドレスを返す */
}

/* メモリを解放する関数を定義 */
void release(island *start)
{
  island *i = start;   /* 開始地点に設定された構造体のポインタを取得 */
  island *next = NULL; /* 次の島のポインタ */

  for (; i != NULL; i = next) {
    next = i->next; /* nextに次の島の構造体のポインタを格納 */
    free(i->name);  /* strdup()関数で作成したname文字列を解放 */
    free(i);        /* island構造体を解放(nameより先に解放するとnameにアクセスできなくなる) */
  }
}

int main()
{
  island *start = NULL; /* 開始地点のポインタ */
  island *i = NULL;     /* 各島のポインタ */
  island *next = NULL;  /* 次の島のポインタ */
  char name[80]; /* 島の名前の文字列配列を格納するメモリを確保 */

  for (; fgets(name, 80, stdin) != NULL; i = next) {
    next = create(name); /* 次の島を作成 */
    /*
     * このとき、何回create()関数を呼び出しても引数には
     * 同じnameメモリ空間のポインタが渡されている
    */

    if (start == NULL) {
      start = next;      /* 最初の島を設定 */
    }
    if (i != NULL) {
      i->next = next;    /* 次の島を設定 */
    }
  }

  display(start);
  release(start);

  return 0;
}

/*
 * ガベージコレクション
 *   ヒープへのデータの割り当てを管理し、データを使わなくなったタイミングで
 *   ヒープからデータを解放する仕組み
*/
