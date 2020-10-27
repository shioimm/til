// 参照: 例解UNIX/Linuxプログラミング教室P248

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <sys/types.h> // closedir, opendir, readdir
#include <dirent.h>    // closedir, opendir, readdir

int main()
{
  DIR *dirp;
  struct dirent *p;

  if ((dirp = opendir(".")) == NULL) {
    perror("opendir");
    exit(1);
  }
  errno = 0;

  while ((p = readdir(dirp)) != NULL) {
    printf("%s\n", p->d_name);
  }

  if (errno != 0) {
    perror("readdir");
    exit(1);
  }

  if (closedir(dirp) != NULL) {
    perror("closedir");
    exit(1);
  }

  return 0;
}
