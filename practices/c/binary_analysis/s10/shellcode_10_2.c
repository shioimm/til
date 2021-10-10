// はじめて学ぶバイナリ解析 不正なコード型コンピュータを守るサイバーセキュリティ技術

#include <stdio.h>

void vuln() {
  char buffer[128];
  printf("%p\n", buffer);
  scanf("%[^\n]", buffer);
}

int main() {
  vuln();
  printf("failed\n");
  return 0;
}

// $ gcc -m32 -z execstack -fno-stack-protector shellcode_10_2.c
// $ sudo sysctl -w
// ASLRをOFFにする
// kernel.randomize_va_space=0
// kernel.randomize_va_space = 0
