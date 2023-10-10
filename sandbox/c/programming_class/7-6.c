// 参照: 例解UNIX/Linuxプログラミング教室P285

#include <stdio.h> // popen, pclose
#include <stdlib.h>

int main()
{
  FILE *fp;
  char buf[1024];

  if ((fp = popen("tee foo1 > foo2", "w")) == NULL) {
    perror("popen");
    exit(1);
  }

  fprintf(fp, "Hello\n");

  pclose(fp);

  return 0;
}
