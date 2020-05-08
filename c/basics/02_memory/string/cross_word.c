/*
 * 引用: Head First C
 * 第2.5章 文字列
*/

#include <stdio.h> /* 標準入出力のためのヘッダファイル */
#include <string.h> /* 文字列操作のためのヘッダファイル */

void print_reverse(char *s)
{
  size_t len = strlen(s);
  char *t = s + len - 1;

  while (t >= s) {
    printf("%c", *t);
    t = t - 1;
  }

  puts("");
}

int main()
{
  char *juices[] = { /* ポインタ配列 -> 配列の要素のアドレスを格納する */
    "dragonfruit",
    "waterberry",
    "sharonfruit",
    "uglifruit",
    "rumberry",
    "kiwifruit",
    "mulberry",
    "strawberry",
    "blueberry",
    "blackberry",
    "startfruit"
  };

  /* 横のカギ */
  char *a;
  puts(juices[6]);
  print_reverse(juices[7]);
  a = juices[2];
  juices[2] = juices[8];
  juices[8] = a;
  print_reverse(juices[(18 + 7) / 5]);

  /* 縦のカギ */
  puts(juices[2]);
  print_reverse(juices[9]);
  juices[1] = juices[3];
  puts(juices[10]);
  print_reverse(juices[1]);

  return 0;
}
