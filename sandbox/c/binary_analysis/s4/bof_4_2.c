// はじめて学ぶバイナリ解析 不正なコード型コンピュータを守るサイバーセキュリティ技術
#include <stdio.h>

int main() {
  int flag = 0;
  char buf[16];

  scanf("%s", buf);

  if (flag != 0) {
    printf("hacked!");
  } else {
    printf("failed!");
  }

  return 0;
}

// $ gcc -m32 -fno-stack-protector bof_4_2.c
