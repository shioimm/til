/*
 * 引用: Head First C
 * 第2章 メモリとポインタ 2
*/

/*
 * 配列変数
 * char quote[] = "Cookies make you fat.";
 * 配列変数quoteが呼ばれるとき、配列の最初の要素"C"が格納されたアドレスに置き換えられる
 * -> 配列変数はポインタのように使用できる
 *
 * ただし配列変数とポインタは同じではない
 * -> quoteをポインタ変数に代入すると配列のサイズの情報が失われる(格下げ)
 *
 * &quote == quote
 * -> 「quote変数のアドレスはquote変数(に格納されたアドレス情報)に等しい」
 *
 *  配列が作成された際、コンピュータは配列を格納するための領域を割り当てるが、
 *  配列変数は実行時に配列のアドレスに置き換えられるため、配列変数はどの領域にも格納されない
*/

/*
 * ポインタ演算
 * int drinks[] = { 1, 2, 3 };
 * printf("最初のオーダー: ドリンク%i杯\n", drinks[i]);
 * printf("最初のオーダー: ドリンク%i杯\n", *(drinks + i));
 * printf("最初のオーダー: ドリンク%i杯\n", *(i + drinks));
 * printf("最初のオーダー: ドリンク%i杯\n", i[drinks]);
 * drinks配列のポインタ値に数値を加算することによってアドレスの位置を指定
 * インデックス(要素の位置) = ポインタ + 要素の位置
*/

#include <stdio.h>

void skip(char *msg)
{
  puts(msg + 6); /* msgポインタに6を加算し、インデックス6以降を表示 */
}

int main()
{
  char *msg_from_amy = "Don't call me.";
  skip(msg_from_amy);

  return 0;
}

/*
 * ポインタの型
 * 型ごとのバイト数単位でポインタ演算が行われる
 * ex. char型 -> 1byte, int型 -> 4byte
*/
