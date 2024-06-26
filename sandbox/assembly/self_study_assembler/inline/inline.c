// 独習アセンブラ
#include <stdio.h>

int main(void) {
  int  i = 123;
  asm("addl $456,%0" : "=r" (i) : "0" (i));
  printf("i = %d\n", i);
  return 0;
}

// asm [volatile] ( プログラムのテンプレート
//                  : 出力の制約と変数名
//                  [ : 入力の制約と式 [ : 破壊されるレジスタ ] ]);
//
// 出力の制約と変数名 - アセンブリ言語プログラムの結果を受け取る方法を指定する
// 入力の制約と式 - アセンブリ言語プログラムにC言語プログラムの式を渡す方法を指定する

// テンプレート:       汎用レジスタ0に456を加算
// 出力の制約と変数名: iはレジスタ0経由で値を受け取る
// 入力の制約と式:     レジスタ0の値をiの値で初期化する


// $ gcc -fno-pic inline.c -o inline
// $ ./inline
// i = 579
