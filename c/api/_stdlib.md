# `#include <stdlib.h>`
#### `malloc` / `realloc` / `free`
```c
void *malloc(size_t size);
void *realloc(void *ptr, size_t size);
void  free(void *ptr);
```

```c
int *i = malloc(sizeof(int));
*i = 5;
free(i);
```

#### `getenv`
- 環境変数を読み取る

```c
char *getenv(const char *name);
```

#### qsort
- 渡された配列の先頭から二つの要素を繰り返し比較し、ソートする

```c
qsort(void *array,      // 配列へのポインタ
      size_t length,    // 配列のサイズ
      size_t item_size, // 配列の各要素のサイズ
      int (*compar)(const void *, const void *)); // コンパレータ関数へのポインタ
```

```
コンパレータ関数

* 配列の要素をソートするための条件を定義する
* 二つの値を比較し、どちらを先に並べたいかをintで返す
  * 最初の値を次の値の後ろに並べる - 正の値を返す
  * 最初の値を次の値の前に並べる   - 負の値を返す
  * 最初の値が次の値と等しい       - 0を返す
```
