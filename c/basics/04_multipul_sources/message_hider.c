/*
 * 引用: head first c
 * 第4章 複数のソースファイルの使用 3
*/

/*
 * 共通化された関数を使用する場合は
 * 対象の関数のヘッダファイルをインクルードする
*/

#include <stdio.h>
#include "encrypt.h" /* encrypt()関数のヘッダをインクルード */

/*
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
 *   1) プリプロセッシング: ヘッダファイルによるソースの調整
 *   2) コンパイル: アセンブリ言語記号への変換
 *   3) アセンブリ: 個々のオブジェクトコード(実際にコンピュータが実行するバイナリコード)の生成
 *   4) リンク: 実行可能プログラムへの組み立て
*/

/*
 * 変更したソースファイルだけを再コンパイルしたい
 * (その他のファイルはコンパイル済みコードのコピーを保存する)
 *   -> コンパイル作業を コンパイル + リンク に分ける
 *
 *   1) 全てのファイルをオブジェクトファイルへコンパイル
 *     $ gcc -c *.c
 *     -> 全ての.cファイルに対して.oファイルを生成する
 *
 *   2) 全てのオブジェクトファイルをリンクして実行可能ファイルを生成
 *     $ gcc *.o -o launch
 *     -> 全ての.oファイルをリンクしてlaunchファイルを生成する
 *
 *   3) 変更したファイルのみ再コンパイル
 *     $ gcc -c thruster.c
 *     -> thruster.cをコンパイルしてthruster.oファイルを生成し直す
 *
 *   4) 再コンパイルしたオブジェクトファイルをリンクしてて実行可能ファイルへ変換
 *     $ gcc *.o -o launch
 *     -> 全ての.oファイルをリンクしてlaunchファイルを生成する
*/

/*
 * ソースファイルの更新日時よりもオブジェクトファイルの生成が遅い場合、
 * ソースファイルの再コンパイルが必要
 *   -> 変更したソースファイルだけを自動で再コンパイルしたい
 *   -> makeツールでビルドを自動化する
 *
 * makeに記述するルール
 *   依存関係 ターゲット(makeがコンパイルするファイル)がどのファイルから生成されるのか
 *   レシピ   ファイルを生成するために実行するべき一連の命令
 *
 * ex. launch実行ファイルが次のファイルによって構成される場合
 *   launch         実行ファイル
 *     launch.o       オブジェクトファイル
 *       launch.c       ソースファイル
 *       launch.h       ソースファイル(ヘッダファイル)
 *       thruster.h     ソースファイル(ヘッダファイル)
 *     thruster.o     オブジェクトファイル
 *       thruster.h     ソースファイル(ヘッダファイル)
 *       thruster.c     ソースファイル
 *
 *   Makefile
 *     launch.o: launch.c launch.h thruster.h    <- ターゲット: 依存関係
 *         gcc -c launch.c                       <- レシピ(コンパイル)
 *     thruster.o: thruster.h thruster.c         <- ターゲット: 依存関係
 *         gcc -c thruster.c                     <- レシピ(コンパイル)
 *     launch: launch.o thruster.o               <- ターゲット: 依存関係
 *         gcc -o launch.o thruster.o -o launch  <- レシピ(リンク)
 *
 *   (レシピ行はタブでインデントする)
 *
 *   $ make launch <- launchファイルを作成するようmakeに指示
 *
 *   makeはコードのコンパイル以外の用途にも使用できる
 *   autoconfによってmakefileの生成を自動化することもできる
*/
