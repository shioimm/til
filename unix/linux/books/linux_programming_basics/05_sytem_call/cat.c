// 引用: ふつうのLinuxプログラミング
// 第5章 ストリームに関わるシステムコール 3
//
// $ cat a b c > out
//   a + b + cを連結(concat)してoutに出力する

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

static void do_cat(const char *path);
static void die(const char *s);

int main(int argc, char *argv[])
{
  int i;

  if (argc < 2) {
    fprintf(stderr, "%s: file name not given\n", argv[0]);
    exit(1);
  }

  for (i = 1; i < argc; i++) { // argv[0]はプログラム本体であるため、i = 1を指定
    do_cat(argv[i]);
  }

  exit(0);
}

#define BUFFER_SIZE 2048

static void do_cat(const char *path) // catコマンドが引数に取るファイルパスを受け取る
{
  int fd;
  unsigned char buf[BUFFER_SIZE];
  int n;

  fd = open(path, O_RDONLY); // 読み込み専用モードでファイルを開き、ファイルディスクリプタ番号を取得

  if (fd < 0) {
    die(path);
  }

  for (;;) {
    n = read(fd, buf, sizeof buf); // ファイルを一行ずつ読み込み、読み込みバイト数を取得

    if (n < 0) { // エラー発生時はdie()を実行
      die(path);
    }
    if (n == 0) { // ファイル終端に至った場合はループをbreak
      break;
    }
    if (write(STDOUT_FILENO, buf, n) < 0) { // 読み込んだバイト数分を標準出力に書き込み
      die(path);                            // エラー発生時はdie()を実行
    }
    if (close(fd) < 0) { // ファイルを閉じる
      die(path);         // エラー発生時はdie()を実行
    }
  }
}

static void die(const char *s)
{
  perror(s); // void perror(const char *s); errnoの値に合わせたエラーメッセージを標準出力
  exit(1);
}
