/*
 * 引用: head first c
 * 第7章 高度な関数 1
*/

/*
 * 関数を定義すると、定数領域に同じ名前の関数ポインタが作成される
 * 関数を呼び出す時、関数ポインタを利用している -> 関数名の実態はポインタ
 *   ex. func()関数がある場合、funcと&funcはいずれもfunc()関数のポインタ
 *
 * 高階関数
 *   関数ポインタ型の引数をとる関数
 *   引数に渡すfunctionデータ型は存在しないため、
 *   関数ポインタ変数は独自に定義する必要がある
 *
 *   悪い例
 *     functionデータ型は存在しない
 *     void func(function *go_to_warp_speed)
 *     {
 *       ...
 *     }
 *
 *   良い例
 *     ポインタを格納する変数を定義し、引数に取る
 *     void func(int** (*go_to_warp_speed)(int))
 *     {
 *       ...
 *     }
 *
 *     int** (*go_to_warp_speed)(int);
 *     -> 返り値の型 | ポインタ変数 | 引数の型
*/

#include <stdio.h>
#include <string.h>

int NUM_ADS = 7;

char *ADS[] = {
  "William: SBM GSOH likes sports, TV, dining",
  "Mat:     SWM NS   likes art, movie, theater",
  "Luis:    SLM ND   likes books, theater, art",
  "Mike:    DWM DS   likes trucks, sports, and bieber",
  "Peter:   SAM      likes chess, working aot and art",
  "Josh:    SJM      likes sports, movie and theater",
  "Jed:     DBM      likes theater, books and dining",
};

int sports_no_bieber(char *s) /* char*型を引数に取り、int型を返す */
{
  return strstr(s, "sports") && !strstr(s, "bieber");
}

/* int** (*match)(char*) -> char*型を引数に取り、int型を返す関数のポインタ定義 */
void find(int** (*match)(char*)) /* 関数ポインタを定義し、引数にとる */
{
  int i;
  puts("検索結果");
  puts("----------------------------");

  for (i = 0; i < NUM_ADS; i++) {
    /* match関数ポインタによって関数を呼び出す (*main)(ADS[i])でも可 */
    if (match(ADS[i])) {
      printf("%s\n", ADS[i]);
    }
  }

  puts("----------------------------");
}

int main()
{
  find(sports_no_bieber);
  /* sports_no_bieber関数ポインタを引数に渡しfindを呼び出す find(&sports_no_bieber);でも可 */
  return 0;
}
