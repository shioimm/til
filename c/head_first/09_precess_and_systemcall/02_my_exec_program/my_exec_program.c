/*
 * 引用: Head First C
 * 第10章 プロセスとシステムコール 2
*/

/*
 * system()関数
 *   子プロセスを生成
 *   生成された子プロセスは与えられた文字列コマンドを実行する
 *
 * exec()関数
 *   現在のプロセスを他のプログラムの実行によって置き換える
 *   exec()の呼び出しを含むプログラムは
 *     -> exec()成功時、即時終了する
 *     -> exec()失敗時、元のプロセスに終了ステータス-1を返す
 *   unistd.hにある
 *
 *   リスト関数
 *     引数リスト(プログラム、引数、NULL)を取る関数
 *       execl()関数
 *         実行ファイル名と引数リストを渡す
 *         $ execl("/home/flynn/clu", "/home/flynn/clu", "paranoids", "contract", NULL);
 *       execlp()関数
 *         PATHで検索できるコマンド名と引数リストを渡す
 *         $ execl("clu", "clu", "paranoids", "contract", NULL);
 *       execle()関数
 *         実行ファイル名と引数リストと環境変数を渡す
 *         $ execl("/home/flynn/clu", "/home/flynn/clu", "paranoids", "contract", NULL, env_vars);
 *
 *  配列関数
 *    引数の配列またはベクトルを取る関数
 *      execv()関数
 *        実行ファイル名と引数の配列またはベクトルを渡す
 *         $ execv("/home/flynn/clu", my_args);
 *      execvp()関数
 *        PATHで検索できるコマンド名と引数の配列またはベクトルを渡す
 *         $ execv("clu", my_args);
 *      execve()関数
 *        実行ファイル名と引数の配列またはベクトルと環境変数を渡す
 *         $ execve("/home/flynn/clu", my_args, env_vars);
*/

#include <stdio.h>
#include <unistd.h>
#include <errno.h>

/* 環境変数を文字列ポインタとして作成 */
char *my_env[] = {
  "JUICE=桃とリンゴ", /* key=value */
  NULL                /* 配列の終端を示すNULL */
};

int main()
{
  /* execle()関数によってdinner_infoを呼び出す */
  execle("dinner_info",
         "dinner_info",
         "4",
         NULL,
         my_env);
  return 0;
}
