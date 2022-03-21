# メソッド定義

```c
typedef mrb_value (*mrb_func_t)(struct mrb_state *mrbb, mrb_value self);

MRB_API void
mrb_define_method(
  mrb_state *mrb, struct RClass *c, const char *name, mrb_func_t func, mrb_aspec aspec
);

MRB_API void
mrb_define_class_method(
  mrb_state *mrb, struct RClass *c, const char *name, mrb_func_t func, mrb_aspec aspec
);

MRB_API void
mrb_define_singleton_method(
  mrb_state *mrb, struct RObject *o, const char *name, mrb_func_t func, mrb_aspec aspec
);

MRB_API void
mrb_define_module_function(
  mrb_state *mrb, struct RClass *c, const char *name, mrb_func_t func, mrb_aspec aspec
);
```

| aspec (メソッドが取りうる引数の種類) | 意味                                               |
| -                                    | -                                                  |
| `MRB_ARGS_NONE()`                    | 引数を取らない                                     |
| `MRB_ARGS_ANY()`                     | 任意の数引数を取る                                 |
| `MRB_ARGS_REQ(n)`                    | 必ずn個の引数を取る                                |
| `MRB_ARGS_OPT(n)`                    | 最大n個のオプション引数をとる                      |
| `MRB_ARGS_ARG(n1, n2)`               | n1個の必須の引数を取り、n2個のオプション引数を取る |
| `MRB_ARGS_BLOCK()`                   | ブロック引数を取る                                 |

#### メソッド引数の取得

```c
MRB_API mrb_int
mrb_get_args(mrb_state *mrb, const char *format, ...);
```

| フォーマット文字 | mrubyでのクラス      | Cでの型                 |
| -                | -                    | -                       |
| `o`              | Object               | `[mrb_value]`           |
| `S`              | String               | `[mrb_value]`           |
| `A`              | Array                | `[mrb_value]`           |
| `H`              | Hash                 | `[mrb_value]`           |
| `s`              | String               | `[char*, mrb_int]`      |
| `z`              | String               | `[char*]`               |
| `a`              | Array                | `[mrb_value*, mrb_int]` |
| `f`              | Fixnum/Float         | `[mrb_float]`           |
| `i`              | Fixnum/Float         | `[mrb_int]`             |
| `b`              | TrueClass/FalseClass | `[mrb_bool]`            |
| `n`              | String/Symbol        | `[mrb_sym]`             |
| `&`              | block                | `[mrb_value]`           |
| `*`              | 残りの引数           | `[mrb_value*, mrb_int]` |

## 参照
- 入門mruby 第9章
