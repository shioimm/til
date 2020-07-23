/*
 * 引用: Head First C
 * 第10章 プロセス間通信 2
*/

#include <stdio.h>
#include <errno.h>
#include <sys/wait.h> /* waitpid() */

void error(char *msg)
{
  fprintf(stderr, "%s: %s\n", msg, strerror(errno));
  exit(1);
}

void open_url(char *url)
{
  char launch[255];
  sprintf(launch, "open '%s'", url); /* 引数のURLをブラウザで開く */
  system(launch);
}

int main(int argc, char *argv[])
{
  char *phrase = argv[1];
  char *vars[] = { "rss_feed=http://www.cnn.com/rss/celebs.xml", null };

  /* パイプのために必要な2つのデータストリームを格納する */
  /* fd[0] 読み込み用ストリーム */
  /* fd[1] 書き込み用ストリーム */
  int fd[2];

  if (pipe(fd) == -1) {
    error("パイプを作成できません");
  }

  pid_t pid = fork(); /* pid 子プロセス */

  if (pid == -1) {
    error("プロセスをフォークできません");
  }

  if (!pid) {
    /* 子プロセスのディスクリプタテーブルを設定する */
    dup2(fd[1], 1); /* 子プロセスの標準出力をパイプの書き込み側に設定 */
    close(fd[0]);   /* 子プロセスは読み込まないのでパイプの読み込み側を閉じる */

    if (execle("/usr/bin/python", "/usr/bin/python", "./rssgossip.py", "-u", phrase, NULL, vars) == -1) {
      error("スクリプトを実行できません");
    }
  }

  /* 親プロセスのディスクリプタテーブルを設定する */
  dup2(fd[0], 0); /* 親プロセスの標準入力をパイプの読み込み側に設定 */
  close(fd[1]);   /* 親プロセスは読み込まないのでパイプの読み込み側を閉じる */
  char line[255];

  while (fgets(line, 255, stdin)) { /* stdin 標準入力は現在パイプの読み込み側に設定されている */
    if (line[0] == '\t') {
      open_url(line + 1); /* line + 1 タブ文字の次から始まる文字列 */
    }
  }
  /*
   * 子プロセスが終了するとパイプが閉じられ、
   * fgets()コマンドがファイルの終端を受け取り、0を返す -> ループが終了する
  */

  return 0;
}

/*
 * ほとんどのパイプはメモリ
 * (ある時点で読み込み、ある時点で書き込む)
 * ファイルを元にした名前付きパイプを作成することもできる -> mkfifo()
 * (二つのプロセスが親子関係ではない場合など)
 *
 * パイプは単方向に機能する
*/
