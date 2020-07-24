/*
 * 新・標準プログラマーズライブラリ C言語 ポインタ完全制覇
 * 第2章 実験してみよう Cはメモリをどう使うのか 1
*/

#include<stdio.h>

int hoge;

int main()
{
  char buf[256];

  printf("&hoge...%p\n", (void*)&hoge);

  printf("Input initial value.\n");
  fgets(buf, sizeof(buf), stdin);
  sscanf(buf, "%d", &hoge);

  for (;;) {
    printf("hoge..%d\n", hoge);
    getchar();
    hoge++;
  }
  return 0;
}

/*
 * &hoge...0x109410038
 * Input initial value.
 *
 * hoge..0
 *
 * hoge..1
 *
 * hoge..2
 *
 * 同時に二つのプログラムを実行しても同じアドレス番地になる
 * それぞれのプログラムで初期設定値を入力すると、
 * それぞれの入力値に応じてインクリメントされる
 *   -> 同じアドレスにそれぞれ別の値を保持している
*/

/*
 * アプリケーションプログラムのメモリ空間には、
 * プロセスごとに独立した仮想アドレス空間が割り当てられる
 *
 * OSが仮想アドレス空間に物理メモリを割り当てる
 *
 * メモリスワッピング
 *   参照されていないデータをハードディスクに退避させてメモリを空ける
*/
