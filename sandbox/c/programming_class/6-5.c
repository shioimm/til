// 参照: 例解UNIX/Linuxプログラミング教室P247

#include <stdio.h>
#include <stdlib.h>
#include <limits.h> // PATH_MAX
#include <unistd.h> // chdir, getcwd

int main()
{
  char cwd[PATH_MAX + 1];

  if (chdir("..") == -1) {
    perror("chdir");
    exit(1);
  }

  if (getcwd(cwd, sizeof(cwd)) == NULL) {
    perror("getcwd");
    exit(1);
  }

  printf("%s\n", cwd);

  return 0;
}
