/*
 * 引用: head first c
 * 第7章 高度な関数 4
*/

#include <stdio.h>
#include <stdarg.h> /* 可変長引数を扱う関数が含まれる */

/*
 * 可変長引数のためのマクロ
 *   va_list  関数に渡した可変個の引数を格納する
 *   va_start 可変個の変数がどこから始まるか示す
 *   va_arg   va_listに格納された可変個の引数を読み取る
 *   va_end   リストを終了させる
 *
 * マクロはプリプロセッサによってコンパイル直前に他のコードに置き換えられる
*/

void print_int(int args, ...) /* ...は引数の省略を意味する */
{
  va_list ap; /* 追加の引数をapに格納する */
  va_start(ap, args); /* 追加の変数apが固定変数のargsの後から始まることを示す */
  int i;

  for (i = 0; i < args; i++) {
    printf("引数%i\n", va_arg(ap, int)); /* va_argはva_listと次の引数の型を引数に取る */
  }

  va_end(ap);
}

enum drink { MUDSLIDE, FUZZY_NAVEL, MONKEY_GLAND, ZOMBIE };

double price(enum drink d)
{
  switch(d) {
    case MUDSLIDE:
      return 6.79;
    case FUZZY_NAVEL:
      return 5.31;
    case MONKEY_GLAND:
      return 4.82;
    case ZOMBIE:
      return 5.89;
  }
  return 0;
}

double total(int args, ...)
{
  double total = 0;
  va_list ap;
  va_start(ap, args);
  int i;

  for (i = 0; i < args; i++) {
    enum drink d = va_arg(ap, enum drink);
    total = total + price(d);
  }

  va_end(ap);
  return total;
}

int main()
{
  print_int(3, 79, 101, 32);
  printf("価格は%.2fです\n", total(3, ZOMBIE, MONKEY_GLAND, FUZZY_NAVEL));

  return 0;
}
