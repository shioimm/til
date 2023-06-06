// Linuxによる並行プログラミング入門 P7

#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include <stdio.h>

int main()
{
  int status;

  if (fork() == 0) {
    puts("child");
  } else {
    // 子プロセスのいずれかが終了するまで待つ
    // statusに終了メッセージを格納する
    wait(&status);
    puts("parent");
    printf("status: %04x\n", status); // 0000
  }
}
