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
 * .hヘッダファイルの共有
 *   - 標準ディレクトリにファイルを置く
 *       #include <encrypt.h>
 *   - include文に絶対パスを指定する
 *       #include "/header_files/encrypt.h"
 *   - gcc -Iオプションを使用する
 *       $ gcc -I/header_files bank_vault.c -o bank_vault
 *       標準ディレクトリに加え、指定したパス以下のディレクトリ内のヘッダファイルも検索する
*/

/*
 * .oオブジェクトファイルの共有
 *   - gcc実行時に絶対パスを指定する
 *       $ gcc -I/header_files bank_vault.c /object_files/encrypt.o -o bank_vault
 *       オブジェクトファイルを共有のオブジェクトファイル用ディレクトリに格納しておく
 *
 *       オブジェクトファイルが複数である場合、
 *       一連のオブジェクトファイルを一つにまとめたアーカイブファイルを指定することも可能
*/

/*
 * .aアーカイブファイルの生成
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
 * アーカイブファイルを利用してプログラムをコンパイル
 *   $ gcc test_code.c -lhfsecurity -o test_code
 *     -lhfsecurity -> libhfsecurityと名前が一致するアーカイブファイルの探索を指示
 *
 *   標準ディレクトリ以外のディレクトリ内にあるアーカイブファイルを探索する場合
 *     -L/オプションで絶対パスを指定
 *     $ gcc test_code.c -L/my_lib -lhfsecurity -o test_code
*/
