/*
 * 新・標準プログラマーズライブラリ c言語 ポインタ完全制覇
 * 第2章 実験してみよう cはメモリをどう使うのか 8
*/


#include <stdio.h>

typedef struct {
  char char1;
  int int1;
  char char2;
  double double1;
  char char3;
  } Hoge;

int main()
{
  Hoge hoge;

  printf("hogesize.. %d\n", (int)sizeof(Hoge));
  printf("hoge..     %p\n", (void*)&hoge);
  printf("char1..    %p\n", (void*)&hoge.char1);
  printf("int1..     %p\n", (void*)&hoge.int1);
  printf("char2..    %p\n", (void*)&hoge.char2);
  printf("double1..  %p\n", (void*)&hoge.double1);
  printf("char3..    %p\n", (void*)&hoge.char3);

  return 0;
}

/*
 * hogesize.. 32
 * hoge..     0x7ffee86067d8
 * char1..    0x7ffee86067d8
 * int1..     0x7ffee86067dc
 * char2..    0x7ffee86067e0
 * double1..  0x7ffee86067e8
 * char3..    0x7ffee86067f0
*/
