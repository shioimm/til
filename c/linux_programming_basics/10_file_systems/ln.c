// 引用: ふつうのLinuxプログラミング
// 第10章 ファイルシステムに関わるAPI 5

// ハードリンク
//   ファイルに対して別の名前を与える
//
//   link(2)
//     実体とリンクは同じファイルシステム上になければいけない
//     実体とリンクどちらにもディレクトリは使えない
//
// リンクカウント
//   そのファイル名が指す実体を指す名前の数
//   rmはファイル名を消す
//   rmによってリンクカウントが0になると実体が消去される

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

  if (link(argv[1], argv[2]) < 0) {
    perror(argv[1]);
    exit(1);
  }

  exit(0);
}
