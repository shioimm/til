// 引用: ふつうのLinuxプログラミング
// 第12章 プロセスに関わるAPI 1

// fork(2)
//   自プロセスを複製して新しいシステムコールをつくる
//   複製前のプロセス(親)と複製後のプロセス(子)はどちらもfork(2)を呼び出した状態
//   -> 親プロセス 子プロセスのプロセスIDを返す
//                 失敗時 -1を返す
//      子プロセス 0を返す
//                 失敗時 子プロセスは作られない(のでfork(2)は呼び出されず何も返さない)
//
// exec
//   自プロセスを新しいプログラムで上書きする
//   exec実行時点で実行されているプログラムは消滅
//   自プロセス上に新しいプログラムをロードして実行する
//   -> 成功時 そのまま終了する(何も返さない)
//      失敗時 -1を返す
//
//   fork() -> exec()
//     プロセス実行中に新しいプログラムを実行し、元のプロセスはそのまま継続
//
// wait(2)
//   fork()して生成された子プロセスのうち、どれか一つが終了するまで待つ
// waitpid(2)
//   fork()して生成された子プロセスのうち、指定したプロセスIDを持つものが終了するまで待つ

// プログラムを実行して結果を待つ
//   1. fork
//   2. 子プロセスで新しいプログラムをexec
//   3. 親プロセスは子プロセスをwait

#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>

int main(int argc, char *argv[])
{
  pid_t pid;

  if (argc != 3) {
    fprintf(stderr, "Usage: %s <command> <arg>\n", argv[0]);
    exit(1);
  }

  pid = fork();

  if (pid < 0) {
    fprintf(stderr, "fork(2) failed\n", argv[0]);
    exit(1);
  }

  if (pid == 0) { // 子プロセス
    execl(argv[1], argv[1], argv[2], NULL);
    // exec失敗時は以下を実行
    perror(argv[1]);
    exit(99);
  } else { // 親プロセス
    int status;
    waitpid(pid, &status, 0); // statusに終了ステータス(マクロ)を格納
    printf("child (PID=%d) finished: ", pid);

    if (WIFEXITED(status)) {                            // WIFEXITED(status) exitによる終了時true
      printf("exit, status=%d\n", WEXITSTATUS(status)); // WEXITSTATUS(status) exitによる終了時、終了コードを返す
    } else if (WIFSIGNALED(status)) {                   // WIFSIGNALED(status) シグナルによる終了時true
      printf("signal, sig=%d\n", WTERMSIG(status));     // WTERMSIG(status) シグナルによる終了時、シグナル番号を返す
    } else {
      printf("abnormal exit\n");
    }
    exit(0);
  }
}
