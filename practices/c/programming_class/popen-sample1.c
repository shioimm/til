// 参照: 例解UNIX/Linuxプログラミング教室P284

#include <stdio.h>     // popen, pclose
#include <stdlib.h>

int main()
{
  FILE *fp;
  char buf[1024];

  if ((fp = popen("ls -l *.c | wc", "r")) == NULL) {
    perror("popen");
    exit(1);
  }

  fgets(buf, sizeof(buf), fp);
  printf("%s", buf);

  pclose(fp);

  return 0;
}
