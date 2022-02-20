# `#include <mruby/value.h>`
#### `mrb_int_value` / `mrb_fixnum_value`
- 数値をRubyのIntegerインスタンスへ変換する

```c
MRB_INLINE mrb_value
mrb_int_value(struct mrb_state *mrb, mrb_int i);
```

```c
MRB_INLINE mrb_value
mrb_fixnum_value(mrb_int i);
```

#### `mrb_float_value`
- 数値をRubyのFloatインスタンスへ変換する

```c
MRB_INLINE mrb_value
mrb_float_value(struct mrb_state *mrb, mrb_float f);
```

#### `mrb_bool_value`
- ブール値をRubyのtrue / falseへ変換する

```c
MRB_INLINE mrb_value
mrb_bool_value(mrb_bool boolean);
```

#### `mrb_true_value`
- Rubyのtrueを返す

```c
MRB_INLINE mrb_value
mrb_true_value();
```


#### `mrb_false_value`
- Rubyのfalseを返す

```c
MRB_INLINE mrb_value
mrb_false_value();
```

#### `mrb_nil_value`
- Rubyのnilを返す

```c
MRB_INLINE mrb_value
mrb_nil_value();
```

#### `mrb_obj_value`
- Rubyレベルの内部型を`mrb_value`型へ変換する

```c
MRB_INLINE mrb_value
mrb_obj_value(void *p);
```

## 参照
- Webで使えるmrubyシステムプログラミング入門 Section022
