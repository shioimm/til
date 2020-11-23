# `#include <mruby.h>`
- 参照: Webで使えるmrubyシステムプログラミング入門 Section019

## `mrb_define_class`
```c
MRB_API struct RClass* mrb_define_class(mrb_state     *mrb,
                                        const char    *name,
                                        struct RClass *super)
```
- `RClass`構造体型のポインタを初期化して新しくクラスを定義する
  - `name` - クラス名
  - `*super` - 親クラス

## `mrb_define_class_method`
```c
MRB_API void mrb_define_class_method(mrb_state     *mrb,
                                     struct RClass *c,
                                     const char    *name,
                                     mrb_func_t     func,
                                     mrb_aspec      aspec)
```
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

## `mrb_get_args`
```c
MRB_API mrb_int mrb_get_args(mrb_state  *mrb,
                             const char *format,
                             ...)
```
- メソッドの引数を取得し、Cで利用できるようにする
  - `format` - メソッドの引数を受け取る際のフォーマット

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
