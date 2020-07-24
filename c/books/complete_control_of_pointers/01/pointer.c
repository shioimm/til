/*
 * 新・標準プログラマーズライブラリ C言語 ポインタ完全制覇
 * 第1章 まずは基礎から 予備知識と復習 1
*/

#include <stdio.h>

int main ()
{
  int hoge = 5;
  int piyo = 10;
  int *hoge_p;

  printf("&hoge..%p\n", (void*)&hoge);
  printf("&piyo..%p\n", (void*)&piyo);
  printf("&hoge_p..%p\n", (void*)&hoge_p);

  hoge_p = &hoge;
  printf("hoge_p..%p\n", (void*)hoge_p);
  printf("*hoge_p..%d\n", *hoge_p);

  *hoge_p = 10;
  printf("hoge..%d\n", hoge);

  return 0;
}
/*
 * &hoge   0x7ffedfe337f8
 * &piyo   0x7ffedfe337f4
 * &hoge_p 0x7ffedfe337e8
 * hoge_p  0x7ffedfe337f8
 * *hoge_p 5
 * hoge    10
*/

/*
 * オペランド(対象)を一つ取る単項演算子
 *   *  間接演算子
 *   &  アドレス演算子
 *   [] 添字演算子
 *   宣言時の「* & []」とは別
*/
