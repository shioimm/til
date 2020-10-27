// 参照: 例解UNIX/Linuxプログラミング教室P260

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h> // closedir, opendir, readdir, lstat
#include <sys/stat.h>  // stat
#include <dirent.h>    // closedir, opendir, readdir
#include <unistd.h>    // chdir, stat

int main(int argc, char *argv[])
{
  struct stat sb;
  DIR *dp;
  struct dirent *dep;
  int i, ndir, nreg, nchr, nblk, nfifo, nsock, nlnk, nunknown;

  if (argc != 2) {
    fprintf(stderr, "usage: files0 <directory>\n");
    exit(1);
  }

  printf("%s\n ", argv[1]);

  if (chdir(argv[1]) != 0) {
    printf("<cannot chdir>\n");
    return 1;
  }

  if ((dp = opendir(".")) == NULL) {
    printf("<cannot list\n>");
    return 1;
  }

  errno = 0;
  ndir = nreg = nchr = nblk = nfifo = nsock = nlnk = nunknown = 0;

  while ((dep = readdir(dp)) != NULL) {
    if (lstat(dep->d_name, &sb) != 0) {
      continue;
    }
    switch (sb.st_mode & S_IFMT) {
      case S_IFDIR:  ndir++;      break;
      case S_IFREG:  nreg++;      break;
      case S_IFCHR:  nchr++;      break;
      case S_IFBLK:  nblk++;      break;
      case S_IFIFO:  nfifo++;     break;
      case S_IFSOCK: nsock++;     break;
      case S_IFLNK:  nlnk++;      break;
      default:       nunknown++;  break;
    }
  }

  ndir -= 2;

  for (i = 0; i < ndir;     i++) putchar('/');
  for (i = 0; i < nreg;     i++) putchar('-');
  for (i = 0; i < nchr;     i++) putchar('%');
  for (i = 0; i < nblk;     i++) putchar('#');
  for (i = 0; i < nfifo;    i++) putchar('|');
  for (i = 0; i < nsock;    i++) putchar('=');
  for (i = 0; i < nlnk;     i++) putchar('@');
  for (i = 0; i < nunknown; i++) putchar('?');

  putchar('\n');
  closedir(dp);

  return 0;
}
