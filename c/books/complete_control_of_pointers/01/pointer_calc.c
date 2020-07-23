/*
 * 新・標準プログラマーズライブラリ C言語 ポインタ完全制覇
 * 第1章 まずは基礎から 予備知識と復習 2
*/

#include<stdio.h>

int main(void)
{
  int hoge;
  int *hoge_p;

  hoge_p = &hoge;

  printf("hoge_p..%p\n", (void*)hoge_p);

  hoge_p++;

  printf("hoge_p..%p\n", (void*)hoge_p);
  printf("hoge_p..%p\n", (void*)(hoge_p + 3));

  return 0;
}
/*
 * hoge_p 0x7ffeef1957e8
 * hoge_p 0x7ffeef1957ec
 * hoge_p 0x7ffeef1957f8
*/
