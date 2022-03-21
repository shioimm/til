# `#include <mruby/value.h>`
#### 真偽値 -> `mrb_value`

```c
MRB_INLINE mrb_value
mrb_bool_value(mrb_bool boolean);
```

#### 値 (`mrb_value`) の取得

```c
MRB_INLINE mrb_value
mrb_true_value();

MRB_INLINE mrb_value
mrb_false_value();

MRB_INLINE mrb_value
mrb_nil_value();
```

#### Rubyレベルオブジェクト -> `mrb_value`

```c
MRB_INLINE mrb_value
mrb_obj_value(void *p);
```

## 参照
- Webで使えるmrubyシステムプログラミング入門 Section022
