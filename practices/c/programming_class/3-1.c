// 参照: 例解UNIX/Linuxプログラミング教室P111

#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>

int main()
{
  int fd;

  if ((fd = open("input3-1.txt", O_RDONLY)) < 0) {
    perror("open");
    exit(1);
  }

  printf("fd = %d\n", fd);

  return 0;
}
