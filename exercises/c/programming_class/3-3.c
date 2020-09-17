// 参照: 例解UNIX/Linuxプログラミング教室P114

#include <fcntl.h>
#include <sys/types.h>
#include <sys/uio.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>

int main()
{
  int fd;
  char buf[6];

  if ((fd = open("hello3-3.txt", O_RDONLY)) < 0) {
    perror("open");
    exit(1);
  }

  if ((read(fd, &buf, 5)) != 5) {
    perror("read");
    exit(1);
  }

  buf[5] = '\0';
  printf("%s\n", buf);

  if ((close(fd)) < 0) {
    perror("close");
    exit(1);
  }

  return 0;
}
