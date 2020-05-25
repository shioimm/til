/*
 * 引用: head first c
 * 第8章 スタティックライブラリとダイナミックライブラリ 2
*/
#include <stdio.h>
#include "hfcal.h" /* display_calories()関数を含む */

int main()
{
  display_calories(115.2, 11.3, 0.79);

  return 0;
}

/*
 * スタティックリンク
 *   オブジェクトコードを一つの実行ファイルに静的にリンクする
 *
 * ダイナミックリンク
 *   オブジェクトコードを個別のファイルに格納し、プログラム実行時に動的にリンクする
*/

/*
 * ダイナミックライブラリのためのオブジェクトコードの生成
 *   $ gcc -I. -fPIC -c hfcal.c -o hfcal.o
 *     -fPIC -> 位置独立コードの生成を指示(省略可能)
 *     -c    -> コードをリンクしない
 *
 * 位置独立コード
 *   コンピュータがそのコードをメモリのどの位置にロードするかを気にしないコード
*/

/*
 * ダイナミックライブラリの生成
 *   $ gcc -shared hfcal.o -o libhfcal.dylib
 *     -shared -> オブジェクトファイルをダイナミックライブラリに変換する
 *     .dylib  -> ダイナミックライブラリ(MacOSの場合)
 *     .so     -> ダイナミックライブラリ(Linuxの場合)
*/

/*
 * コンパイル手順
 *   1) ライブラリのオブジェクトファイルの生成
 *     $ gcc -I. -fPIC -c hfcal.c -o hfcal.o
 *     $ gcc -I. -fPIC -c hfcal-UK.c -o hfcal.o 別のソースファイルを利用する際に再生成
 *   2) ダイナミックライブラリの生成
 *     $ gcc -shared hfcal.o -o libhfcal.dylib
 *   3) オブジェクトファイルの生成
 *     $ gcc -c -c elliptial.c -o elliptial.o
 *   3) オブジェクトファイルのリンクおよび実行
 *     $ gcc elliptial.o -L. -lhfcal -o elliptial && ./elliptial
*/
