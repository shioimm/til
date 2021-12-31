# C文法

```c
/* sample.c */

/* 標準入出力を行うためのヘッダファイルを読み込む */
#include <stdio.h>

int main() {
  int   x = 10;    /* %d */
  float y = 1.0; /* %f */
  char  z = 'a';  /* %c */

  printf("x = %d, y = %f, z = %c\n", x, y, z);

  return 0;
}
```

```
# ソースファイルsample.cを実行ファイルsampleに変換する
$ gcc -o sample sample.c

# 実行ファイルを呼び出す
$ ./sample
```

## 条件分岐
```c
#include <stdio.h>

int main() {
  // if文
  int size = 10;

  if (size > 8) {
      printf("Bigger than 8\n");
  } else if (size > 5) {
      printf("Bigger than 5\n");
  } else {
      printf("Smaller than 5\n");
  }

  // switch文
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

// 三項演算子
int getBigger(int x, int y) {
  return (x > y) ? x : y;
}

int main() {
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

int main() {
  // while文
  int x = 0;

  while (x < 10) {
    printf("x = %d\n", x);
    x++;
  }

  // 後置while文
  int y = 0;

  do {
    printf("y = %d\n", y);
    x++;
  } while (y < 0);

  // for文
  int z = 0;

  for (x = 0; z < 10; z++) {
    printf("z = %d\n", z);
  }

  // continue -> スキップ / break -> ループを抜ける

  return 0;
}
```

## 関数
```c
#include <stdio.h>

// プロトタイプ宣言
int addition(int x, int y);
void printHello(void);

// 返り値・引数が存在する場合 (型を指定する)
int addition(int x, int y) {
  return x + y;
}

// 返り値・引数が存在しない場合
void printHello(void) {
  printf("Hello/n");
}

// main関数 (最初に読み込まれる)
int main() {
  int result;
  result = addition(1, 1);

  printf("%d\n", result);

  printHello();

  return 0; // 慣習的に0を返す
}
```

## 静的変数
```c
#include <stdio.h>

void plusOne(void) {
  // 静的変数として宣言 -> 二回めの呼び出し以降、変数定義が無視される
  static int x = 0;
  x++;
  printf("x = %d\n", x);
}

int main() {
  plusOne; // -> 1
  plusOne; // -> 2
  plusOne; // -> 3

  return 0;
}
```

## 配列
```c
#include <stdio.h>

int main(){
  int x[3]; // int型のメモリ領域を3つ連続して確保

  x[0] = 10:
  x[1] = 20;
  x[2] = 30;

  printf("%d\n", x[0]); // -> 10

  int y[3] = { 10, 20, 30 };
  // 要素数が同じ場合は int y[] = { 10, 20, 30 }; でも可

  printf("%d\n", y[0]); // -> 10

  return 0;
}
```

## 文字列
```c
#include <stdio.h>

// 文字列 = char型の配列
char x[] = { 'H', 'e', 'l', 'l', 'o', '\0' };
char y[] = "Hello";

int main() {
  char z[] = "Hello";

  printf("%c\n", z[0]); /* -> H */

  return 0;
}
```

## ポインタ
- メモリアドレスの値を格納する変数
```
#include <stdio.h>

int main() {
  int  x; // アドレスa~a+4に、int型の値を格納するメモリ領域を確保 -> xと命名
  x =  1; // x領域に値1を代入する
  int *y; // int型の値が格納された領域を指すアドレスを格納するメモリ領域を確保 -> yと命名
  y = &x; // yにxのアドレスを格納
          // & -> アドレス演算子

  printf("%d\n", *y); // アドレスが示している値を出力
                      // * -> 間接演算子

  return 0;
}
```

```c
#include <stdio.h>

void plusOne(int *y) { // 引数としてアドレスの値を受け取る
  *y = *y + 1;
  printf("%d", y);
}

int main() {
  int x = 1;
  plusOne(&x); // 引数としてアドレスを渡し、値に対して直接操作を行う
               // -> 2

  return 0;
}

// 引数に値ではなくアドレスを渡すことによりメモリを節約することができる
// アドレスが保有している値を直接操作することにより破壊的操作を行うことができる
```

## メモリ関連のバグ
#### メモリリーク
- `free()`し忘れ
- メモリを浪費する

#### ぶらぶらポインタ
- 存在しない領域を指す不正なポインタ
- `free()`後に書き込みを行うなど

#### バッファオーバーラン
- 確保した領域の大きさを超えたデータの書き込み

## 参照
- 例解UNIX/Linuxプログラミング教室P69-76
