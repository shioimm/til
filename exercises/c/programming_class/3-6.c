// 参照: 例解UNIX/Linuxプログラミング教室P124

#include <fcntl.h>     // open
#include <sys/types.h> // read
#include <sys/uio.h>   // read
#include <unistd.h>    // read / write / lseek / close
#include <stdio.h>     // printf / fflush
#include <stdlib.h>    // exit

int main()
{
  int d, cc;
  char buf[5];
  off_t pos;

  if ((d = open("input3-6.file", O_RDONLY)) < 0) {
    perror("open");
    exit(1);
  }

  if ((pos = lseek(d, 10, SEEK_SET)) < 0) {
    perror("lseek");
    exit(1);
  }

  printf("new offset = %d\n", (int)pos);

  if ((cc = read(d, buf, sizeof(buf))) < 0) {
    perror("read");
    exit(1);
  }

  if ((pos = lseek(d, 10, SEEK_CUR)) < 0) {
    perror("lseek");
    exit(1);
  }

  close(d);

  printf("offset after read = %d\n", (int)pos);
  printf("number of bytes read = %d\n", cc);
  fflush(stdout);

  if (cc > 0) {
    write(STDOUT_FILENO, buf, cc);
  }

  putchar('\n');

  return 0;
}
