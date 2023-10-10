// はじめて学ぶバイナリ解析 不正なコード型コンピュータを守るサイバーセキュリティ技術
#include <stdio.h>

void pwn() {
  printf("hacked!");
}

void vuln() {
  char overflowme[48];

  scanf("%[^\n]", overflowme);
}

int main() {
  vuln();
  printf("failed!");
  return 0;
}

// $ gcc -m32 -fno-stack-protector bof_8_1.c
// $ sudo sysctl -w
// ASLRをOFFにする
// kernel.randomize_va_space=0
// kernel.randomize_va_space = 0
