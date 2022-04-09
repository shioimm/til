# 指定子
#### `extern`
- 外部のファイルで定義済み

#### `restrict`
- 当該ポインタの参照先オブジェクトは、当該ポインタ経由以外の方法では変更されない
  - ポインタ型に対してのみ適用可能
  - コンパイラに対する最適化のヒントとして明示する

```c
int* restrict i;
```

#### `static`
- 外部のファイルからの参照を禁止する
- (ローカル変数の場合) 静的変数とする

```c
#include <stdio.h>

void plus_one(void) {
  // 静的変数として宣言 -> 二回めの呼び出し以降、変数定義が無視される
  static int x = 0;
  x++;
  printf("x = %d\n", x);
}

int main() {
  plus_one; // -> 1
  plus_one; // -> 2
  plus_one; // -> 3

  return 0;
}
```

#### `typedef`
- 既存のデータ型に新しい名前を付ける

```c
// unsigned char -> uchar
typedef unsigned char uchar;

// struct -> user_table
typedef struct {
  char name[255];
} user_table;
```

#### `volatile`
- コンパイラの最適化を抑止する
