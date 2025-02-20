# volatile
- コンパイラによる最適化を抑止する

```c
int main(void)
{
  volatile int i = 0;

  while (i == 0) {} // volatileがない場合 while(1) に最適化される

  return 0;
}
```

- `setjmp`の前後で変数の値が意図しない形で変更されることを防ぐために利用される

```c
#include <stdio.h>
#include <setjmp.h>

jmp_buf env;

void func() {
  longjmp(env, 1);  // setjmpにジャンプ
}

int main() {
  volatile int i = 1;

  if (setjmp(env) == 0) {
      i = 2;  // ローカル変数に異なる値を代入
      func(); // longjmpを呼び出し
  } else {
      printf("i = %d\n", i);
      // i = 2 が出力される
      // int i にvolatileを付与しない場合は i = 1 か i = 2 か不定
      // volatileを付与することでコンパイラが i をレジスタではなくメモリ上に確保し
  }

  return 0;
}
```
