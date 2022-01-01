# 宣言
#### `extern`
- 外部のファイルで定義済み

#### `static`
- 外部のファイルからの参照を禁止する
- (ローカル変数のみ) 静的変数とする

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

#### `typedef`
- 既存のデータ型に新しい名前を付ける

```c
typedef unsigned char uchar; // unsigned char -> uchar

typedef struct { char name[255] } user_table; // struct -> user_table
```

#### `volatile`
- コンパイラの最適化を抑止する
