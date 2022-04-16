# extern
- 外部で定義済みの変数を宣言する

```c
// prog1.c

int i = 1; // 変数の定義
```

```c
// prog2.c

#include <stdio.h>

extern int i; // 変数の宣言

int main(void)
{
  printf("%d\n", i); // 変数の利用

  return 0;
}
```

## 参照
- 新・C言語入門 シニア編 P71
