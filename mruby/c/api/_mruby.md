# `#include <mruby.h>`
#### `mrb_define_class`
- `RClass`構造体型のポインタを初期化して新しくクラスを定義する
  - `name` - クラス名
  - `*super` - 親クラス

```c
MRB_API struct rclass*
mrb_define_class(mrb_state *mrb, const char *name, struct RClass *super);
```

#### `mrb_define_const`
- モジュール`mod`の下に`name`の名前で定数を定義する

```c
MRB_API void
mrb_define_const(mrb_state *mrb, struct RClass *mod, const char *name, mrb_value v);
```

#### `mrb_define_class_method`
- クラスにクラスメソッドを定義する
  - `c` - クラス
  - `name` - メソッド名
  - `func` - 関数ポインタ
    - `mrb_state *mrb` / `mrb_value self`を引数にとり、`mrb_value`型を返す
  - `aspec` - メソッドが取りうる引数の指定
    - `MRB_ARGS_NONE()` - 引数を取らない
    - `MRB_ARGS_ANY()` - 任意の数引数を取る
    - `MRB_ARGS_REQ(n)` - 必ずn個の引数を取る
    - `MRB_ARGS_OPT(n)` - 最大n個のオプション引数をとる
    - `MRB_ARGS_ARG(n1, n2)` - n1個の必須の引数を取り、n2個のオプション引数を取る
    - `MRB_ARGS_BLOCK()` - ブロック引数を取る

```c
MRB_API void
mrb_define_class_method(mrb_state *mrb, struct RClass *c, const char *name, mrb_func_t func, mrb_aspec aspec);
```

#### `mrb_get_args`
- メソッドの引数を取得し、Cで利用できるようにする
  - `format` - メソッドの引数を受け取る際のフォーマット

```c
MRB_API mrb_int
mrb_get_args(mrb_state *mrb, const char *format, ...);
```

| 文字 | mrubyでのクラス      | Cでの型                 |
| -    | -                    | -                       |
| `o`  | Object               | `[mrb_value]`           |
| `S`  | String               | `[mrb_value]`           |
| `A`  | Array                | `[mrb_value]`           |
| `H`  | Hash                 | `[mrb_value]`           |
| `s`  | String               | `[char*, mrb_int]`      |
| `z`  | String               | `[char*]`               |
| `a`  | Array                | `[mrb_value*, mrb_int]` |
| `f`  | Fixnum/Float         | `[mrb_float]`           |
| `i`  | Fixnum/Float         | `[mrb_int]`             |
| `b`  | TrueClass/FalseClass | `[mrb_bool]`            |
| `n`  | String/Symbol        | `[mrb_sym]`             |
| `&`  | block                | `[mrb_value]`           |
| `*`  | 残りの引数           | `[mrb_value*, mrb_int]` |

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

#### `mrb_funcall`
- mrubyのRubyレベルのメソッドを飛び出し返り値を受け取る
  - `self` - レシーバ
  - `*name` - 呼び出すメソッド
  - `argc` - 引数の数
  - `...` - 引数の値

```c
MRB_API mrb_value
mrb_funcall(mrb_state *mrb, mrb_value self, const char *name, mrb_int argc, ...);
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

#### `mrb_inspect`
- mrubyのオブジェクトを人間の読みやすいStringへ変換する

```c
MRB_API mrb_value
mrb_inspect(mrb_state *mrb);
```

#### `mrb_p`
- `mrb_value`の示す値を表示する

```c
MRB_API void
mrb_p(mrb_state*, mrb_value);
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