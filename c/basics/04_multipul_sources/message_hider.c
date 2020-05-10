/*
 * 引用: head first c
 * 第4章 複数のソースファイルの使用
*/

/*
 * 共通化された関数を使用する場合は
 * 対象の関数のヘッダファイルをインクルードする
*/

#include <stdio.h>
#include "encrypt.h" /* encrypt()関数の宣言をインクルードする */

/*
 * encrypt.h
 *   void encrypt(char *message)
 *
 * encrypt.c
 *   #include "encrypt.h"
 *
 *   void encrypt(char *message)
 *   {
 *     while(*message) {
 *       *message = *message ^ 31;
 *       message++;
 *     }
 *   }
*/

int main()
{
  char msg[80];

  while(fgets(msg, 80, stdin)) {
    encrypt(msg);
    printf("%s", msg);
  }

  return 0;
}

/*
 * 必要なソースファイルによってコンパイルを実行
 * $ gcc message_hider.c encrypt.c -o message_hider && message_hider
 *   I am a secret message.
 *   V?~r?~?lz|mzk?rzll~xz1%
*/

/*
 * gccによるコンパイルの手順
 *   1) プリプロセッシング(ヘッダファイルによるソースの調整)
 *   2) コンパイル(アセンブリへの変換)
 *   3) オブジェクトコードへの変換
 *   4) リンク(実行可能プログラムの組み立て)
*/

/*
 * 変更したソースファイルだけを再コンパイルしたい
 * (その他のファイルはコンパイル済みコードのコピーを保存する)
 *   -> コンパイル作業を コンパイル + リンク に分ける
 *
 *   1) 最初に全てのファイルをオブジェクトファイルへコンパイル
 *     $ gcc -c *.c
 *   2) 全てのオブジェクトファイルをリンクして実行可能ファイルへ変換
 *     $ gcc *.o -o launch
 *   3) 変更したファイルのみ再コンパイル
 *     $ gcc -c thruster.c
 *   4) 再コンパイルしたオブジェクトファイルをリンクしてて実行可能ファイルへ変換
 *     $ gcc *.o -o launch
*/

/*
 * 変更したソースファイルだけを自動で再コンパイルしたい
 *   -> makeツールでビルドを自動化する
 *
 * makeに記述するルール
 *   依存関係 ターゲットがどのファイルから生成されるのか
 *   レシピ   ファイルを生成するために実行するべき一連の命令
 *
 * ex. launch実行ファイルが次のファイルによって構成される場合
 *   launch
 *     launch.o
 *       launch.c
 *       launch.h
 *       thruster.h
 *     thruster.o
 *       thruster.h
 *       thruster.c
 *
 *   Makefile
 *     launch.o: launch.c launch.h thruster.h    <- 依存関係
 *         gcc -c launch.c                       <- コンパイルレシピ
 *     thruster.o: thruster.h thruster.c         <- 依存関係
 *         gcc -c thruster.c                     <- コンパイルレシピ
 *     launch: launch.o thruster.o               <- 依存関係
 *         gcc -o launch.o thruster.o -o launch  <- リンクレシピ
 *
 *   (レシピ行はタブでインデントする)
 *
 *   $ make launch
 *
 *   makeはコードのコンパイル以外の用途にも使用できる
 *   autoconfによってmakefileの生成を自動化することもできる
*/
