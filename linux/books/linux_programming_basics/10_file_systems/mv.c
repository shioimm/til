// 引用: ふつうのLinuxプログラミング
// 第10章 ファイルシステムに関わるAPI 8

// ファイルを移動する -> 一つの実体に対する名前を付け替える(rename(2))
//   別のハードリンクを作ってから元の名前を消す

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(int argc, char *argv[])
{
  int i;

  if (argc != 3) {
    fprintf(stderr, "%s: wrong arguments\n", argv[0]);
    exit(1);
  }

  if (rename(argv[1], argv[2]) < 0) {
    perror(argv[i]);
    exit(1);
  }

  exit(0);
}
