// 引用: ふつうのLinuxプログラミング
// 第10章 ファイルシステムに関わるAPI 10

// 付帯情報を変更する
//   chmod(2)
//     パーミッションの変更
//   chown(2)
//     オーナーとグループの変更
//   utime(2)
//     最終アクセス時刻と最終更新時刻の変更

#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>

int main(int argc, char *argv[])
{
  int mode;
  int i;

  if (argc < 2) {
    fprintf(stderr, "no mode given\n");
    exit(1);
  }

  mode = strtol(argv[1], NULL, 0); // 文字列をlong値に変換

  for (i = 2; i < argc; i++) {
    if (chmod(argv[i], mode) < 0) {
      perror(argv[i]);
    }
  }

  exit(0);
}
