// 参照: 例解UNIX/Linuxプログラミング教室P126

#include <fcntl.h>     // open
#include <sys/types.h> // read
#include <sys/uio.h>   // read
#include <unistd.h>    // read / write / lseek / close
#include <stdio.h>     // printf / fflush
#include <stdlib.h>    // exit

int main()
{
  int d, i;

  if ((d = open("hop3-7.out", O_WRONLY|O_CREAT|O_TRUNC, 0666)) < 0) {
    perror("open");
    exit(1);
  }

  for (i = 0; i < 8;i++) {
    if (write(d, "hop", 3) < 0) {
      perror("write");
      exit(1);
    }
    if (lseek(d, 3, SEEK_CUR) < 0) {
      perror("lseek");
      exit(1);
    }
  }

  close(d);

  return 0;
}
