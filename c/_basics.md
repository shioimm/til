# C言語
## 基本構文、実効
```c
/* sample.c */

/* 標準入出力を行うためのヘッダーファイルを読み込む */
#include <stdio.h>

main() {
    int x = 10;    /* %d */
    float y = 1.0; /* %f */
    char z = 'a';  /* %c */

    printf("x = %d, y = %f, z = %c\n", x, y, z);
}
```
- 実行時、ソースファイルを実効ファイルに変換する
```sh
$ gcc -o sample.c
```
- 実効ファイルを呼び出す
```sh
$ sample.c
```

## 条件分岐
```c
#include <stdio.h>

main() {
    /* if文 */
    int size = 10;

    if (size > 8) {
        printf("Bigger than 8\n");
    } else if (size > 5) {
        printf("Bigger than 5\n");
    } else {
        printf("Smaller than 5\n");
    }

    /* switch文 */
    char character = "a";

    switch(character) {
        case a:
            printf("The character is a.\n");
            break;
        case b:
            printf("The character is b.\n");
            break;
        default:
            printf("The character is something else.\n");
            break;
    }
}
```
```c
#include <stdio.h>

/* 三項演算子 */
int getBigger(int x, int y) {
  return (x > y) ? x : y;
}

main() {
    int x = 1;
    int y = 2;

    int result;
    result = getBigger(x, y);

    printf("%d\n", result)
}
```
## ループ
```c
#include <stdio.h>

main() {
    /* while文 */
    int x = 0;

    while (x < 10) {
        printf("x = %d\n", x);
        x++;
    }

    /* 後置while文 */
    int y = 0;

    do {
      printf("y = %d\n", y);
      x++;
    } while (y < 0);

    /* for文 */
    int z = 0;

    for (x = 0; z < 10; z++) {
      printf("z = %d\n", z);
    }

    /* continue -> スキップ / break -> ループを抜ける */
}
```

## 関数
```c
#include <stdio.h>

/* プロトタイプ宣言 */
int addition(int x, int y);
void printHello(void);

/* 返り値・引数が存在する場合(型を指定する) */
int addition(int x, int y) {
    return x + y;
}

/* 返り値・引数が存在しない場合 */
void printHello(void) {
    printf("Hello/n");
}

/* メイン関数(最初に読み込まれる) */
main() {
    int result;
    result = addition(1, 1);

    printf("%d\n", result);

    printHello();
}
```

## 静的変数
```c
#include <stdio.h>

void plusOne(void) {
    /* 静的変数として宣言 -> 二回めの呼び出し以降、変数定義が無視される */
    static int x = 0;
    x++;
    printf("x = %d\n", x);
}

main() {
  plusOne; /* -> 1 */
  plusOne; /* -> 2 */
  plusOne; /* -> 3 */
}
```

## 配列
```c
#include <stdio.h>

main() {
    int x[3]; /* 領域を確保 */

    x[0] = 10:
    x[1] = 20;
    x[2] = 30;

    printf("%d\n", x[0]); /* -> 10 */

    int y[3] = { 10, 20, 30 };
    /* 要素数が同じ場合はint y[] = { 10, 20, 30 };でも可 */

    printf("%d\n", y[0]); /* -> 10 */
}
```

## 文字列
```c
#include <stdio.h>

/* 文字列 = char型の配列 */
char x[] = { "H", "e", "l", "l", "o", "\0" };
char y[] = "Hello";

main() {
  char z[] = "Hello";

  printf("%c\n", z[0]); /* -> H */
}
```
