/*
 * 新・標準プログラマーズライブラリ C言語 ポインタ完全制覇
 * 第1章 まずは基礎から 予備知識と復習 6
*/

#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>

/* 関数の引数として配列を渡したい場合、先頭要素へのポインタを渡す */
int get_word(char *buf, int buf_size, FILE *fp)
{
  /*
   * 関数の仮引数の宣言の場合に限り、buf[]と*bufは同じ意味を指す
   *   int get_word(char buf[], int buf_size, FILE *fp)
   *   int get_word(char buf[10], int buf_size, FILE *fp)
   *   -> int get_word(char *buf, int buf_size, FILE *fp)に変換される
  */

  int len;
  int ch;

  while ((ch = getc(fp)) != EOF && !isalnum(ch));

  if (ch == EOF) {
    return EOF;
  }

  len = 0;

  do {
    buf[len] = ch;
    len++;

    if (len >= buf_size) {
      fprintf(stderr, "word too long");
      exit(1);
    }
  } while ((ch = getc(fp)) != EOF && !isalnum(ch));

  buf[len] = '\0';

  rerurn len;
}

int main()
{
  char buf[256];

  while (get_word(buf, 256, stdin) != EOF) {
    printf("<<%s>>\n", buf)
  }

  return 0;
}
