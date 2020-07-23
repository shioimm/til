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
 *   関数ポインタの宣言
 *     誤) function *f;
 *         -> functionデータ型は存在しない(関数の型は一つではないため)
 *
 *     正) int (*warp_fn)(int);
 *         -> 関数のアドレスを格納できるwarp_fn変数
 *            返り値の型 | ポインタ変数 | 引数の型
 *
 *         warp_fn = go_to_warp_speed;
 *         -> warp_fn変数にgo_to_warp_speed()関数ポインタを格納
 *
 *         warp_fn(4);
 *         -> 引数4でgo_to_warp_speed()関数を呼び出す
*/

/* char** -> 文字列の配列を指すために使用するポインタ */

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

/* int (*match)(char*) -> char*型を引数に取り、int型を返すmatch()関数を引数にとる */
void find(int (*match)(char*))
{
  int i;
  puts("検索結果");
  puts("----------------------------");

  for (i = 0; i < NUM_ADS; i++) {
    /* match()関数ポインタによって引数に渡された関数を呼び出す */
    if (match(ADS[i])) { /* (*main)(ADS[i])でも可 */
      printf("%s\n", ADS[i]);
    }
  }

  puts("----------------------------");
}

int main()
{
  /*
   * sports_no_bieber()関数ポインタを引数としてfind()関数を呼び出す
   * find(&sports_no_bieber);でも可
  */
  find(sports_no_bieber);

  return 0;
}
