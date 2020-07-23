/*
 * 引用: Head First C
 * 第10章 プロセス間通信 1
*/

/*
 * 各プロセスは独立したディスクリプタテーブルを持つ
 *
 * fileno() 指定したファイルのディスクリプタを返す
 * dup2()   データストリームを複製し、上書きされたディスクリプタを返す
*/

#include <stdio.h>
#include <errno.h>
#include <sys/wait.h> /* waitpid() */

void error(char *msg)
{
  fprintf(stderr, "%s: %s\n", msg, strerror(errno));
  exit(1);
}

int main(int argc, char *argv[])
{
  char *phrase = argv[1];
  char *vars[] = { "rss_feed=http://www.cnn.com/rss/celebs.xml", null };
  FILE *f      = fopen("stories.txt", "w");

  if (!f) {
    error("stories.txtを開けません");
  }

  pid_t pid = fork();

  if (pid == -1) {
    error("プロセスをフォークできません");
  }

  if (!pid) {
    /* ディスクリプタ1のデータストリームをfileno(f)のデータストリーム(stories.txt)に上書き */
    /* dup2()は上書きされた方のディスクリプタ(1)を返す */
    if (dup2(fileno(f), 1) == 1) {
      error("標準出力をリダイレクトできません");
    }

    if (execle("/usr/bin/python", "/usr/bin/python", "./rssgossip.py", phrase, NULL, vars) == -1) {
      error("スクリプトを実行できません");
    }
  }

  int pid_status;

  /*
   * pid        プロセスID
   * pid_status プロセスに関する終了情報を格納する
   * 0          オプション(0はプロセスが完了するまで待機する)
   */
  if (waitpid(pid, &pid_status, 0) == -1) {
    error("子プロセスの待機エラー");
  }

  return 0;
}

/*
 * WEXITSTATUS(pid_status) 子プロセスの終了ステータスを返すマクロ
 * pid_statusにはビット毎に複数の情報が含まれ、最初の8ビットのみが終了状態を表す
 * WEXITSTATUSは8ビットの値のみを通知する
*/
