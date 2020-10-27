// 参照: 例解UNIX/Linuxプログラミング教室P121

#include <fcntl.h>     // open
#include <sys/types.h> // read
#include <sys/uio.h>   // read
#include <unistd.h>    // read / write / close
#include <stdio.h>     // printf
#include <stdlib.h>    // exit

int main()
{
  int ifd;
  size_t cc;
  char buf[1024];

  if ((ifd = open("input3-5.file", O_RDONLY)) < 0) {
    perror("open");
    exit(1);
  }

  while ((cc = read(ifd, buf, sizeof(buf))) > 0) {
    if (write(STDOUT_FILENO, buf, cc) < 0) {
      perror("write");
      exit(1);
    }
  }

  if (cc < 0) {
    perror("read");
    exit(1);
  }

  if (close(ifd) < 0) {
    perror("close");
    exit(1);
  }

  return 0;
}
