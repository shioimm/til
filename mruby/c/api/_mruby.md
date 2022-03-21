# `#include <mruby.h>`
#### `mrb_malloc`
- mrubyで使うデータのための領域を割り当て、そのポインタを返す

```c
MRB_API void*
mrb_malloc(mrb_state *mrb, size_t len);
```

#### `mrb_free`
- `mrb_malloc`により割り当てられた領域を解放する

```c
MRB_API void*
mrb_free(mrb_state *mrb, void *p);
```

#### `mrb_intern_lit`
- 文字列リテラルの名前に相当する`mrb_sym`を返す

```c
mrb_sym
mrb_intern_lit(mrb_state *mrb, const char *lit);
```

#### `mrb_open`
- `mrb_state*`を初期化しmruby VMを作る

```c
MRB_API mrb_state*
mrb_open(void);
```

#### `mrb_close`
- `mrb_state*`を閉じ、解放する

```c
MRB_API mrb_state*
mrb_close(mrb_state *mrb);
```

#### `mrb_p`
- `mrb_value`の値を標準出力

```c
MRB_API void
mrb_p(mrb_state *mrb, mrb_value);
```


#### `DATA_PTR` (マクロ)
- インスタンスが持つCレベルのデータへのアクセス
  - `RData`構造体`data`メンバへのアクセス

```c
DATA_PTR(self)
```

#### `DATA_TYPE` (マクロ)
- インスタンスが持つCレベルのデータを解放する方法
  - `RData`構造体`type`メンバへのアクセス
- インスタンス一つ一つのデータ解放の振る舞いにアクセスする

```c
DATA_TYPE(self)
```

## 参照
- webで使えるmrubyシステムプログラミング入門 section019 / 022 / 033 / 034
