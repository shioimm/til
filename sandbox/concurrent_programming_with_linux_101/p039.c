// Linuxによる並行プログラミング入門 P39

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

int main()
{
  int fd;

  // p039_fileを書き出し専用にオープン = オープンしたファイルに対する新しいfdが作成される
  fd = open("practices/concurrent_programming_with_linux_101/p039_file",
            O_WRONLY | O_CREAT, 0664);
  close(1); // 標準出力を閉じる
  dup(fd);  // 開いているfd (1) へp039_fileへのfdをコピー
  execlp("cat", "cat", NULL);
}
