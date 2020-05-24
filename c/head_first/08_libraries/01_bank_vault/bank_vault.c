/*
 * 引用: head first c
 * 第8章 スタティックライブラリとダイナミックライブラリ 1
*/

/*
 * 標準ヘッダディレクトリは/usr/local/include
 * サードパーティライブラリは/usr/include に格納されていることが多い
*/
#include <stdio.h>

/* カレントディレクトリに格納されている自作ライブラリ */
#include "encrypt.h"
#include "checksum.h"

int main()
{
  char s[] = "Speak friend and enter";
  encrypt(s);

  printf("'%s'に暗号化しました\n", s);
  printf("チェックサムは%iです\n", checksum(s));

  encrypt(s);
  printf("'%s'に復号化しました\n", s);
  printf("チェックサムは%iです\n", checksum(s));

  return 0;
}

/*
 * 自作の.hヘッダファイルを共有する場合
 *   - 標準ディレクトリにファイルを置く
 *       #include <encrypt.h>
 *   - include文に絶対パスを指定する
 *       #include "/path/to/encrypt.h"
 *   - コンパイラに絶対パスを指定する
 *       $ gcc -I /path/to/test_code.c /path/to/encrypt.o -o test_code
 *       ヘッダファイルをヘッダファイルディレクトリ、
 *       オブジェクトファイルをオブジェクトファイルディレクトリに格納しておく
 *       一連のオブジェクトファイルを一つにまとめたアーカイブファイルを指定することも可能
*/

/*
 * アーカイブファイル.aの作成
 *   $ ar -rcs libhfsecurity.a encrypt.o checksum.o
 *     -r                   -> .aファイルがすでに存在する場合は置き換える
 *     -c                   -> フィードバックなしにアーカイブを作成する
 *     -s                   -> .aファイルの先頭にインデックスを作成する
 *     libhfsecurity.a      -> .aファイル名 名前がlibで始まるものはスタティックライブラリ
 *     encrypt.o checksum.o -> アーカイブに格納するファイル
 *
 * アーカイブファイル.aの中身
 *   $ nm libhfsecurity.a
 *   ---
 *   libhfsecurity.a(encrypt.o):
 *   0000000000000000 T _encrypt
 *   libhfsecurity.a(checksum.o):
 *   0000000000000000 T _checksum
 *   ---
 *   Tはテキスト、関数名は_encryptまたは_checksum
 *
 * 作成したアーカイブファイルはライブラリ用ディレクトリに格納する
*/

/*
 * プログラムをコンパイル
 *   アーカイブファイルをライブラリディレクトリに格納した場合
 *     $ gcc test_code.c -lhfsecurity -o test_code
 *       -hfsecurity -> libhfsecurity.aの探索を指示
 *
 *   アーカイブファイルを他のディレクトリに格納した場合
 *     $ gcc test_code.c -L/my_lib -lhfsecurity -o test_code
*/
