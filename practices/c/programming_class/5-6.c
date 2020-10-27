// 参照: 例解UNIX/Linuxプログラミング教室P192

#include <stdio.h>
#include <stdlib.h> // getenv

int main()
{
  char *pathstr;

  if ((pathstr = getenv("PATH")) != NULL) {
    printf("PATH=%s\n", pathstr);
  } else {
    printf("PATH not set");
  }

  return 0;
}
