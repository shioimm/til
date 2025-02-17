// 引用: ふつうのLinuxプログラミング
// 第10章 ファイルシステムに関わるAPI 6

// シンボリックリンク
//   ファイル名に対して別の名前を与える
//   シンボリックリンクへのアクセス毎にリンク先のファイル名を検索し、
//   リンク先のファイル名から実体を検索する
//
//     symlink(2)
//       シンボリックリンクには対応する実態が存在しなくても良い
//       シンボリックリンクはファイルシステムを跨いでリンクを貼ることができる
//       シンボリックリンクはディレクトリに対してもリンクを貼ることができる

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(int argc, char *argv[])
{
  int i;

  if (argc != 3) {
    fprintf(stderr, "%s: wrong number of arguments\n", argv[0]);
    exit(1);
  }

  if (symlink(argv[1], argv[2]) < 0) {
    perror(argv[1]);
    exit(1);
  }

  exit(0);
}
