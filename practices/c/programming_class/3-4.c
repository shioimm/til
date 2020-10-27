// 参照: 例解UNIX/Linuxプログラミング教室P117

#include <fcntl.h>     // open
#include <sys/types.h> // read
#include <sys/uio.h>   // read
#include <unistd.h>    // read / write / close
#include <stdio.h>     // printf
#include <stdlib.h>    // exit

#define INFILE "input3-4.file"
#define OUTFILE "output3-4.file"

enum {
  BUF_SIZE = 1024,
};

int main()
{
  int ifd, ofd;
  char buf[BUF_SIZE];
  size_t cc;

  if ((ifd = open(INFILE, O_RDONLY)) < 0) {
    perror("open input.file");
    exit(1);
  }

  if ((ofd = open(OUTFILE, O_WRONLY|O_CREAT|O_TRUNC, 0666)) < 0) {
    perror("open output.file");
    exit(1);
  }

  while ((cc = read(ifd, buf, sizeof(buf))) > 0) {
    if (write(ofd, buf, cc) < 0) {
      perror("write");
      exit(1);
    }
  }

  if (cc < 0) {
    perror("read");
    exit(1);
  }

  if ((close(ifd)) < 0) {
    perror("close input.file");
    exit(1);
  }

  if ((close(ofd)) < 0) {
    perror("close output.file");
    exit(1);
  }

  return 0;
}
