# C言語
## 基本構文、実効
```c
/* sample.c */

/* 標準入出力を行うためのヘッダーファイルを読み込む */
#include <stdio.h>

int main()
{
    int x = 10;    /* %d */
    float y = 1.0; /* %f */
    char z = 'a';  /* %c */

    printf("x = %d, y = %f, z = %c\n", x, y, z);

    return 0;
}
```
- 実行時、ソースファイルsample.cを実効ファイルsampleに変換する
```sh
$ gcc -o sample sample.c
```
- 実効ファイルを呼び出す
```sh
$ ./sample
```

## 条件分岐
```c
#include <stdio.h>

int main()
{
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

    return 0;
}
```
```c
#include <stdio.h>

/* 三項演算子 */
int getBigger(int x, int y) {
  return (x > y) ? x : y;
}

int main()
{
    int x = 1;
    int y = 2;

    int result;
    result = getBigger(x, y);

    printf("%d\n", result);

    return 0;
}
```
## ループ
```c
#include <stdio.h>

int main()
{
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

    return 0;
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
int main()
{
    int result;
    result = addition(1, 1);

    printf("%d\n", result);

    printHello();

    return 0; /* 慣習的に0を返す */
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

int main()
{
  plusOne; /* -> 1 */
  plusOne; /* -> 2 */
  plusOne; /* -> 3 */

  return 0;
}
```

## 配列
```c
#include <stdio.h>

int main()
{
    int x[3]; /* 領域を確保 */

    x[0] = 10:
    x[1] = 20;
    x[2] = 30;

    printf("%d\n", x[0]); /* -> 10 */

    int y[3] = { 10, 20, 30 };
    /* 要素数が同じ場合はint y[] = { 10, 20, 30 };でも可 */

    printf("%d\n", y[0]); /* -> 10 */

    return 0;
}
```

## 文字列
```c
#include <stdio.h>

/* 文字列 = char型の配列 */
char x[] = { 'H', 'e', 'l', 'l', 'o', '\0' };
char y[] = "Hello";

int main()
{
  char z[] = "Hello";

  printf("%c\n", z[0]); /* -> H */

  return 0;
}
```

## ポインタ
- メモリアドレスの値を格納する変数
```
#include <stdio.h>

int main()
{
    int x; /* アドレスa~a+4に、int型の値を格納する領域を確保 -> xと命名 */
    x = 1; /* x領域に値1を代入する */

    int *y; /* アドレスb~b+4に、「int型の値が格納された領域」を指しているアドレスを格納する領域を確保 -> yと命名 */
    y = &x; /* yにxのアドレスを格納 */
            /* & -> アドレス演算子 */

    printf("%d\n", *y); /* アドレスが示している値を出力 */
                        /* * -> 間接演算子 */

    return 0;
}
```

## 参照渡し
- 関数の引数にアドレスを渡す -> 参照渡し
- 関数の引数に直接値を渡す -> 値渡し
```c
#include <stdio.h>

void plusOne(int *y) { /* 引数としてアドレスを受け取る */
    *y = *y + 1;
    printf("%d", y);
}

int main()
{
    int x = 1;
    plusOne(&x); /* 引数としてアドレスを渡し、値に対して直接操作を行う */
                 /* -> 2 */

    return 0;
}
```
- 引数に値ではなくアドレスを渡すことによりメモリを節約することができる
- アドレスが保有している値を直接操作することにより破壊的操作を行うことができる

## ポインタ操作
- 参照: 例解UNIX/Linuxプログラミング教室P69-76
- アドレス演算(`&`)
- ポインタ変数宣言(`*`)
  - `int *p` - int型のデータを格納するメモリ領域の先頭アドレスを格納する変数p
- 関節演算(`*`)

### ポインタの間違い
#### 未初期化ポインタ変数の関節演算
```c
int *p;
*p = 999;

// 初期化時にポインタ変数*pに参照先のアドレスが割り当てられていない
// 代入時にポインタ変数*pが指すアドレス領域が空のままであるためエラー
```

#### 未初期化ポインタ変数を引数に渡す
```c
#include <time.h> // time_t time(time_t *t);

time_t *t;
time(t);

// 初期化時にポインタ変数*tに参照先のアドレスが割り当てられていない
// 変数tはどこも指していないためエラー
// time(&t);またはで変数tへのアドレスを渡す
```

#### ローカル変数へのポインタを返り値にする
```c
int *foo()
{
  int x;
  return &x;
}

// return時にローカル変数は消えるため
// 存在しない領域を指すポインタを返すことになりエラー
```

#### ポインタが指す先が未初期化
```c
#include <sys/types.h>
#include <socket.h> // int accept(int s, struct sockaddr *addr, socklen_t *addrlen);

int sock = socket(AF_INET, SOCK_STREAM, 0);
struct sockaddr_storage client_addr;
unsigned int address_size;

accept(sock, (struct sockaddr *)&client_addr, &address_size);

// 変数address_sizeが実際に指し示す先がないためエラー
// unsigned int address_size = sizeof(client_addr);
```

## メモリ関連のバグ
- メモリリーク
  - `free()`し忘れ
  - メモリを浪費する
- ぶらぶらポインタ
  - 存在しない領域を指す不正なポインタ
  - `free()`後に書き込みを行うなど
- バッファオーバーラン
  - 確保した領域の大きさを超えたデータの書き込み
