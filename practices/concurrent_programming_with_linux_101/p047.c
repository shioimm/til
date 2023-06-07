// Linuxによる並行プログラミング入門 P47

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>

int main()
{
  // 名前付きpipe (FIFO) p47_pipe を作成
  if (mknod("practices/concurrent_programming_with_linux_101/p47_pipe", S_IFIFO | 0664, 0) == 0) {
    printf("p47_pipe is created\n");
  } else {
    printf("p47_pipe exists\n");
  }
}
