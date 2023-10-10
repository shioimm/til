// Linuxによる並行プログラミング入門 P8

#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>

int main()
{
  int status;

  if (fork() == 0) {
    puts("child");
    exit(3);
  } else {
    pid_t cpid;
    cpid = wait(&status);
    puts("parent");
    printf("status: %04x\n", status); // 0300
    printf("cpid: %d\n", cpid); // 子プロセスのpid
  }
}
