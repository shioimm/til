# static
- 静的領域上に保存される変数の宣言

#### 内部結合グローバル変数の宣言
- リンカに渡さず、ファイルの中のみで使用するグローバル変数を宣言する

```c
static int i; // 外部のファイルからの参照を禁止する
```

#### 静的変数の宣言
- 関数の処理が終わった後も破棄されず、値を保持する変数を宣言する

```c
#include <stdio.h>

void plus_one(void) {
  // 静的変数として宣言 -> 二回めの呼び出し以降、変数定義が無視される
  static int x = 0;
  x++;
  printf("x = %d\n", x);
}

int main(void) {
  plus_one; // -> 1
  plus_one; // -> 2
  plus_one; // -> 3

  return 0;
}
```

## 参照
- 新・C言語入門 シニア編 P77
