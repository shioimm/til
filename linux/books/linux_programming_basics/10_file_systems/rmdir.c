// 引用: ふつうのLinuxプログラミング
// 第10章 ファイルシステムに関わるAPI 4

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(int argc, char *argv[])
{
  int i;

  if (argc < 2) {
    fprintf(stderr, "%s: no argument error\n", argv[0]);
    exit(1);
  }

  for (i = 1; i < argc; i++) {
    if (rmdir(argv[i]) < 0) {
      perror(argv[i]);
      exit(1);
    }
  }

  exit(0);
}
