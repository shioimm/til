// 引用: ふつうのLinuxプログラミング
// 第10章 ファイルシステムに関わるAPI 3

// mkdir()システムコールが失敗する原因
//   ENOENT  親ディレクトリがない
//   ENOTDIR 親ディレクトリに該当するパスが親ディレクトリではない
//   EEXIST  すでにファイルやディレクトリが存在する
//   EPERM   親ディレクトリを変更する権限がない

// umask
//   プロセスの属性の一つ(Ex. 8進数の022)
//   パーミッションはmodeからumaskに含まれるビット数を落とした数値

#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <sys/types.h>

int main(int argc, char *argv[])
{
  int i;

  if (argc < 2) {
    fprintf(stderr, "%s: no arguments\n", argv[0]);
    exit(1);
  }

  for (i = 1; i < argc; i++) {
    if (mkdir(argv[i], 0777) < 0) {
      perror(argv[i]);
      exit(1);
    }
  }

  exit(0);
}
