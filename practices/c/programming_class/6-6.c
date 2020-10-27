// 参照: 例解UNIX/Linuxプログラミング教室P253

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h> // symlink

int main(int argc, char *argv[])
{
  if (argc != 3) {
    fprintf(stderr, "usage %s <file> <symbolic link>\n", argv[0]);
    exit(1);
  }

  if (symlink(argv[1], argv[1]) == -1) {
    perror("symlink");
    exit(1);
  }

  return 0;
}
