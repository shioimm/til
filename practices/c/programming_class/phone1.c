// 参照: 例解UNIX/Linuxプログラミング教室P127

#include <sys/types.h> // lseek / open / read / write
#include <stdlib.h>    // exit
#include <stdio.h>     // fprintf / perror / printf
#include <string.h>    // memset
#include <sys/stat.h>  // open
#include <fcntl.h>     // open
#include <sys/uio.h>   // read / write
#include <unistd.h>    // close / lseek / read / write
#include "mysub.h"

#define PHONEBOOK "phone1.dat"

enum {
  RECLEN = 32
};

void show(int);
void input(int);

int main()
{
  int fd;
  int cmd, finish;

  if ((fd = open(PHONEBOOK, O_RDWR|O_CREAT, 0666)) < 0) {
    perror("open");
    exit(1);
  }

  finish = 0;

  while (!finish) {
    cmd = getint("commanf (0=show, 1=input, 2=end)");
    switch (cmd) {
      case 0:
        show(fd);
        break;
      case 1:
        input(fd);
        break;
      case 2:
        finish = 1;
        break;
      default:
        fprintf(stderr, "unknown command %d\n", cmd);
        break;
    }
  }

  if (close(fd) < 0) {
    perror("close");
    exit(1);
  }

  return 0;
}

void show(int fd)
{
  int recno;
  ssize_t cc;
  char rec[RECLEN + 1];
  rec[RECLEN] = '\0';
  recno = getint("record number? ");

  if (lseek(fd, recno * RECLEN, SEEK_SET) < 0) {
    perror("lseek");
    return;
  }
  if ((cc = read(fd, rec, RECLEN)) < 0) {
    perror("read");
    return;
  }
  if (cc == 0) {
    printf("no item\n");
  } else {
    printf("item = \"%s\"\n", rec);
  }

  return;
}

void input(int fd)
{
  int recno;
  char rec[RECLEN + 1];

  memset(rec, 0, sizeof(rec));
  recno = getint("record number? ");

  if (lseek(fd, recno * RECLEN, SEEK_SET) < 0) {
    perror("lseek");
    return;
  }
  getstr("name? ", rec, sizeof(rec));

  if (write(fd, rec, RECLEN) != RECLEN) {
    perror("write");
    return;
  }

  return;
}
