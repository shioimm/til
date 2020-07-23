/*
 * 引用: Head First C
 * 第10章 プロセス間通信 3
*/

/*
 * シグナルはシグナルマッピングテーブルでハンドラと対応づけられる
 * シグナルを捕捉して独自のコードを実行するためにはsigactionを使用する
 *   sigactionは関数へのポインタを持つstruct
 *     int catch_signal(int sig, void (*handler)(int))
 *     {
 *       struct sigaction action;
 *       action.sa_handler = handler; ハンドラで実行したい関数名
 *       sigemptyset(&action.sa_mask) ; マスクはsigactionが対処するシグナルをフィルタリングする
 *       action.sa_flags = 0;           追加のフラグを0に設定
 *       return sigaction(sig, &action, NULL);
 *     }
 *
 *   sigaction()はsigactionをOSに登録する
 *     sigaction(signal_no, &new_action, &old_action);
 *       signal_no   登録したいシグナル番号(SIGINTやSIGQUITなど)
 *       &new_action 登録したい新しいsigactionのアドレス
 *       &old_action 置き換えようとしている現在のハンドラのアドレス(置き換えない場合はNULL)
 *
 *   ハンドラに設定したい関数
 *     void handler(int sig) ハンドラが捕捉するシグナル番号を引数に取る
 *     {
 *       exit(1);
 *     }
 *
 *     catch_signal(SIGINT, handler);
 *
*/

#include <stdio.h>
#include <signal.h> /* sigaction */
#include <stdlib.h>

void diediedie(int sig)
{
  puts("残酷な世界よさようなら…");
  exit(1);
}

int catch_signal(int sig, void (*handler)(int))
{
  struct sigaction action;
  action.sa_handler = handler;
  sigemptyset(&action.sa_mask);
  action.sa_flags = 0;
  return sigaction(sig, &action, NULL);
}

int main()
{

  if (catch_signal(SIGINT, diediedie) == -1) {
    fprintf(stderr, "ハンドラを設定できません");
  }

  char name[30];
  printf("名前を入力してください: ");
  fgets(name, 30, stdin);
  printf("こんにちは%sさん\n", name);

  return 0;
}

/*
 * SIGINT   プロセスが割り込まれた
 * SIGQUIT  プロセスを停止してコアダンプファイルにメモリをダンプするよう要求された
 * SIGFPE   浮動小数点エラー
 * SIGTRAP  デバッガがプロセスの実行箇所を尋ねた
 * SIGSEGV  プロセスが不正なメモリにアクセスしようとした
 * SIGWINCH 端末ウィンドウのサイズが変更された
 * SIGTERM  カーネルのプロセスに終了を要求した
 * SIGPIPE  プロセスが誰も読み込んでいないパイプに書き込んだ
 *
 * SIGALRM  alerm()で設定されたタイマーが終了した際に発行
 *            各プロセスはタイマーを一つ持てる
 *            処理の自動切替によるマルチタスクに利用できる
 * SIG_DFL  ハンドラのデフォルト値(変更したハンドラを元に戻す時に使う)
 * SIG_IGN  シグナルを無視する
*/
