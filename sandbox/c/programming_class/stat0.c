// 参照: 例解UNIX/Linuxプログラミング教室P258

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h> // stat
#include <sys/stat.h>  // stat
#include <unistd.h>    // stat

int main(int argc, char *argv[])
{
  struct stat sb;

  if (stat(argv[1], &sb) < 0) {
    perror("stat");
    exit(1);
  }

  printf("Information for %s:\n", argv[1]);
  printf("  st_ino   = %d\n", (int)sb.st_ino);
  printf("  st_mode  = %o\n", (int)sb.st_mode);
  printf("  st_nlink = %d\n", (int)sb.st_nlink);
  printf("  st_uid   = %d\n", (int)sb.st_uid);
  printf("  st_gid   = %d\n", (int)sb.st_gid);
  printf("  st_size  = %d\n", (int)sb.st_size);

  return 0;
}
