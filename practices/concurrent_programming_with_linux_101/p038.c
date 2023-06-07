// Linuxによる並行プログラミング入門 P38

#include <stdio.h>
#include <unistd.h>

int main()
{
  int fd;

  fd = dup(1);
  write(1,  "test message\n", 13);
  write(fd, "test message\n", 13);
  printf("fd: %d\n", fd); // fd: 3
  // fd: 1 (標準出力) にfd: 3をコピー
  // fd: 3 はfd: 1と同じものを参照するようになる
}
