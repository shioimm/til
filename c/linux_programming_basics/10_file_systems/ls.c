// 引用: ふつうのLinuxプログラミング
// 第10章 ファイルシステムに関わるAPI 2

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <dirent.h>

static void do_ls(char *path);

int main(int argc, char *argv[])
{
  int i;

  if (argc < 2) {
    fprintf(stderr, "%s: no arguments\n", argv[0]);
    exit(1);
  }

  for (i = 1; i < argc; i++) {
    do_ls(argv[i]);
  }

  exit(0);
}

static void do_ls(char *path)
{
  DIR *d;
  struct dirent *ent;

  d = opendir(path); // pathのディレクトリを開く

  if (!d) {
    perror(path);
    exit(1);
  }

  while (ent = (readdir(d))) { // エントリがなくなるまでエントリ名を出力
    printf("%s\n", ent->d_name);
  }

  closedir(d); // ディレクトリを閉じる
}

// トラバース
//   ディレクトリツリーを再帰的に辿る
//
//   void traverse(path)
//   {
//     DIR *d = opendir(path);
//     struct dirent *ent;
//
//     while (ent = readdir(d)) {
//       if (entがディレクトリの場合) {
//         traverse(path/ent); <- ..を排除していないため無限再帰に陥る
//       }
//       何かする
//     }
//   }
