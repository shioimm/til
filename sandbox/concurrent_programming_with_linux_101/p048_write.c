// Linuxによる並行プログラミング入門 P48

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>

int main()
{
  int pfd, rfd;
  char c;

  if ((pfd = open("practices/concurrent_programming_with_linux_101/p047_pipe", O_WRONLY)) == -1) {
    exit(1);
  }

  if ((rfd = open("practices/concurrent_programming_with_linux_101/p041_oldfile", O_RDONLY)) == -1) {
    exit(1);
  }

  while (read(rfd, &c, 1) != 0) { // rfdから読み込む
    write(pfd, &c, 1);            // pfdへ書き込む
  }
}
