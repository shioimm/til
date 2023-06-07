// Linuxによる並行プログラミング入門 P48

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>

int main()
{
  int pfd;
  char c;

  if ((pfd = open("practices/concurrent_programming_with_linux_101/p047_pipe", O_RDONLY)) == -1) {
    exit(1);
  }

  while (read(pfd, &c, 1) != 0) { // pfdから読み込む
    write(1, &c, 1);              // 1へ書き込む
  }
}
