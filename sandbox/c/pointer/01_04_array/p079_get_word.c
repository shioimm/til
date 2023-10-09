// 新・標準プログラマーズライブラリ C言語 ポインタ完全制覇 P79

#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>

// 関数の仮引数の宣言の場合に限り配列の宣言はポインタに読み替えられる
// func(char buf[])はfunc(char *buf)のシンタックスシュガー)
int get_word(char *buf, int buf_size, FILE *fp)
{
  int len;
  int c;

  while ((c = getc(fp)) != EOF && !isalnum(c));

  if (c == EOF) {
    return EOF;
  }

  len = 0;
  do {
    printf("c.. %c\n", c);
    buf[len] = c;
    len++;
    if (len >= buf_size) {
      fprintf(stderr, "word too long.\n");
      exit(1);
    }
  } while ((c = getc(fp)) != EOF && isalnum(c));

  buf[len] = '\0';

  return len;
}

int main(void)
{
  char buf[256];

  // get_word()にbuf char buf配列の先頭のポインタが渡される
  while (get_word(buf, 256, stdin) != EOF) {
    printf("<<%s>>\n", buf);
  }

  return 0;
}
