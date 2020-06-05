/*
 * 新・標準プログラマーズライブラリ C言語 ポインタ完全制覇
 * 第2章 実験してみよう Cはメモリをどう使うのか 6
*/

#include <stdio.h>
#include <stdarg.h> /* 可変長引数のためのマクロを定義 */
#include <assert.h>

void tiny_printf(char *format, ...)
{
  int i;
  va_list ap; /* va_list型のポインタ(?) */

  va_start(ap, format); /* apを引数のformatの次の位置に設定する */

  for (i = 0; format[i] != '\0'; i++) {
    switch (format[i]) {
      case 's':
        printf("%s ", va_arg(ap, char*));
        break;
      case 'd':
        printf("%d ", va_arg(ap, int));
        break;
      default:
        assert(0); /* assert() -> 引数が偽の場合強制終了 */
    }
  }

  va_end(ap);
  putchar('\n');
}

int main()
{
  tiny_printf("sdd", "result..", 3, 5);

  return 0;
}
