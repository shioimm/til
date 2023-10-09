// 参照: 例解UNIX/Linuxプログラミング教室P111

#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main()
{
  int fd;

  if ((fd = open("empty3-2.file", O_WRONLY|O_CREAT|O_TRUNC, 0666)) < 0) {
    perror("open output.file");
    exit(1);
  }

  if (close(fd) < 0) {
    perror("close");
    exit(1);
  }

  return 0;
}
