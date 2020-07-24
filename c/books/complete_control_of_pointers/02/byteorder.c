/*
 * 新・標準プログラマーズライブラリ c言語 ポインタ完全制覇
 * 第2章 実験してみよう cはメモリをどう使うのか 9
*/

#include <stdio.h>

int main()
{
  int hoge = 0x12345678;
  unsigned char *hoge_p = (unsigned char*)&hoge;
  printf("%x\n", hoge_p[0]);
  printf("%x\n", hoge_p[1]);
  printf("%x\n", hoge_p[2]);
  printf("%x\n", hoge_p[3]);

  return 0;
}

/*
 * 78
 * 56
 * 34
 * 12
 *
 * バイトの並び方 -> バイトオーダー(CPUによって異なる)
 *   整数型がメモリ上に降順で配置される -> リトルエンディアン
 *   整数型がメモリ上に昇順で配置される -> ビッグエンディアン
*/
