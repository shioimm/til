# `#include <mruby/class.h>`
#### `mrb_class_get`
```c
MRB_API struct RClass* mrb_class_get(mrb_state  *mrb,
                                     const char *name);
```

- 定義済みの既存のクラスの`RClass`構造体へのポインタを探して返す

#### `mrb_define_class_under`
```c
MRB_API struct RClass* mrb_define_class_under(mrb_state     *mrb,
                                              struct RClass *outer,
                                              const char    *name,
                                              struct RClass *super);
```

- `outer`に指定したクラスの下に`super`を親クラスとするクラスを定義する

## マクロ
#### `MRB_SET_INSTANCE_TT(struct RClass *c, enum mrb_vtype tt)`
- 当該クラス`c`のインスタンス一般についてのデータタイプを指定する
- 特定のクラスに所属するインスタンス全体についてのmrubyでの扱いを指定する

## 参照
- Webで使えるmrubyシステムプログラミング入門 Section022
