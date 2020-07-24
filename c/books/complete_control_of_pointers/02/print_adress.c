/*
 * 新・標準プログラマーズライブラリ C言語 ポインタ完全制覇
 * 第2章 実験してみよう Cはメモリをどう使うのか 2
*/

#include<stdio.h>
#include<stdlib.h>

int global_variable;
static int file_static_variable;

void func1()
{
  int func1_variable;
  static int local_static_variable;

  printf("&func1_variable..%p\n", (void*)&func1_variable);
  printf("&local_static_variable..%p\n", (void*)&local_static_variable);
}

void func2()
{
  int func2_variable;

  printf("&func2_variable..%p\n", (void*)&func2_variable);
}

int main()
{
  int *p;

  /* 関数へのポインタ(先頭アドレス) */
  printf("func1..%p\n", (void*)func1);
  /* func1..0x10b709d90 */
  printf("func2..%p\n", (void*)func2);
  /* func2..0x10b709dd0 */

  /* 文字列リテラルのアドレス(先頭要素へのポインタ) */
  printf("string literal..%p\n", (void*)"abc");
  /* string literal..0x10b709f64 */

  /* グローバル変数アドレスの表示 */
  printf("&global_variable..%p\n", (void*)&global_variable);
  /* &global_variable..0x10b70a028 */

  /* ファイル内static変数のアドレス */
  printf("&file_static_variable..%p\n", (void*)&file_static_variable);
  /* &file_static_variable..0x10b70a024 */

  /* ローカル変数 */
  func1();
  /* &func1_variable..0x7ffee44f67ac */
  /* &local_static_variable..0x10b70a020 */

  func2();
  /* &func2_variable..0x7ffee44f67ac */

  /* malloc()によって確保した領域のアドレス */
  p = malloc(sizeof(int));
  printf("malloc address..%p\n", (void*)p);
  /* malloc address..0x7fe018c00620 */

  return 0;
}

/*
 * アドレス領域
 *   0x10b709d90付近
 *     関数
 *     文字列リテラル
 *
 *   0x10b70a028付近
 *     ファイル内static変数
 *     staticローカル変数
 *     グローバル変数
 *
 *   0x7fe018c00620付近
 *     malloc()によって確保した領域
 *
 *   0x7ffee44f67ac付近
 *     自動変数(ローカル変数)
*/
