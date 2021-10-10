// はじめて学ぶバイナリ解析 不正なコード型コンピュータを守るサイバーセキュリティ技術
#include <stdio.h>
#include <stdlib.h>

char global[] = "/bin/sh";

void vuln() {
  printf("global: %p\n", global);
  printf("文字列を入力してください");

  char overflowme[32];
  scanf("%[^\n]", overflowme);
}

int main() {
  vuln();
  printf("failed!\n");
  return 0;
}


// $ gcc -m32 -fno-stack-protector bof_8_1.c
// $ sudo sysctl -w
// ASLRをOFFにする
// kernel.randomize_va_space=0
// kernel.randomize_va_space = 0
