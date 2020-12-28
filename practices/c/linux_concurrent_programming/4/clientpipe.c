// 引用: Linuxによる並行プログラミング入門 第4章 リダイレクトとパイプ 4.7

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>

int main()
{
  if (mknod("request", S_IFIFO | 0664, 0) == 0) {
    printf("request created\n");
  } else {
    printf("request exists\n");
  }

  if (mknod("response1", S_IFIFO | 0664, 0) == 0) {
    printf("response1 created\n");
  } else {
    printf("response1 exists\n");
  }

  if (mknod("response1", S_IFIFO | 0664, 0) == 0) {
    printf("response1 created\n");
  } else {
    printf("response1 exists\n");
  }
}
