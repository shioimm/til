// 参照: 例解UNIX/Linuxプログラミング教室P130

#include <sys/types.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/uio.h>
#include <unistd.h>
#include "mysub.h"

#define PHONEBOOK "phone2x.dat"

enum {
  NAMELEN = 32,
  PHONELEN = 16,
};

struct person {
  char name[NAMELEN + 1];
  char phone[PHONELEN + 1];
  int isprivate;
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
    cmd = getint("command (0=show, 1=input, 2=end)? ");
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
  struct person rec;

  recno = getint("record number? ");

  if (lseek(fd, recno * sizeof(rec), SEEK_SET) < 0) {
    perror("lseek");
    return;
  }
  if ((cc = read(fd, &rec, sizeof(rec))) < 0) {
    perror("read");
    return;
  }
  if (cc == 0) {
    printf("no item\n");
  } else {
    printf("item = {%d, \"%s\", \"%s\"}\n", rec.isprivate, rec.name, rec.phone);
  }

  return;
}

void input(int fd)
{
  int recno;
  struct person rec;

  memset(&rec, 0, sizeof(rec));
  recno = getint("record number?");

  if (lseek(fd, recno * sizeof(rec), SEEK_SET) < 0) {
    perror("lseek");
    return;
  }

  getstr("name? ", rec.name, NAMELEN + 1);
  getstr("phone? ", rec.phone, PHONELEN + 1);
  rec.isprivate = getint("private? ");

  if (write(fd, &rec, sizeof(rec)) < 0) {
    perror("write");
    return;
  }

  return;
}
