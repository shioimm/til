# プロプロセッサディレクティブ
#### `#include`
- ヘッダの挿入

#### `#define`
- マクロの定義
- プリプロセッサによってコンパイル前にソースコード中のマクロ名がマクロ値に置き換えられる

```c
#define ADD_ONE(x) ((x) + 1)

prrintf("%i\n", ADD_ONE(2)); // => 3
```

#### `#ifdef` / `#else` / `#endif`
- 条件付きコンパイル

```c
#ifdef SPANISH
  char *msg = "Hola";
#else
  char *msg = "Hello";
#endif
```

## 参照
- Head First C
