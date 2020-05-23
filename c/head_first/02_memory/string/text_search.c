/*
 * 引用: Head First C
 * 第2.5章 文字列 1
*/

#include <stdio.h> /* 標準入出力のためのヘッダファイル */
#include <string.h> /* 文字列操作のためのヘッダファイル */

/* 文字列の配列をグローバルに宣言 */
char tracks[][80] = { /* 収録されている全曲リスト */
  /*
   * []   -> 外側の配列にアクセス
   *         コンパイラが要素数を判断するため[5]とする必要はない
   * [80] -> 配列の要素の各詳細にアクセス
   *         要素ごとに文字数が異なるため、文字列の最大長を指定してメモリを確保する
  */
  "I left my heart in Harvard Med School",
  "Newark, Newark - a wonderful town",
  "Dancing with a Dork",
  "From here to maternity",
  "The girl from Iwo Jima",
};

void find_track(char search_for[])
{
  int i;
  for (i = 0; i < 5; i++) {
    if (strstr(tracks[i], search_for)) {
      printf("曲番号%i: %s\n", i, tracks[i]);
    }
  }
}

int main()
{
  char search_for[80];
  printf("検索語: ");
  fgets(search_for, 80, stdin);
  search_for[strlen(search_for) - 1] = '\0';
  find_track(search_for);

  return 0;
}

/*
 * string.h
 *   strchr() 文字列内にある文字の位置を返す
 *   strcmp() 文字列同士を比較する
 *   strstr() 文字列内にある別の文字列の位置を返す
 *   strcpy() 文字列を別の文字列にコピーする
 *   strlen() 文字列長を求める
 *   strcat() 文字列同士を連結する
*/
