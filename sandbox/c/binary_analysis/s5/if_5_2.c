// はじめて学ぶバイナリ解析 不正なコード型コンピュータを守るサイバーセキュリティ技術
#include <stdio.h>

int main() {
  int a;
  a = 0;

  if (a != 0) {
    printf("hacked!\n");
  } else {
    printf("failed!\n");
  }

  return 0;
}
