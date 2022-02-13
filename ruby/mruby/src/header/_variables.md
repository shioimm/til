# `#include <mruby/variable.h>`
#### `mrb_iv_set`
- `mrb_value`の`v`を`obj`のインスタンス変数へセットする

```c
MRB_API void
mrb_iv_set(mrb_state *mrb, mrb_value obj, mrb_sym sym, mrb_value v);
```

## 参照
- Webで使えるmrubyシステムプログラミング入門 Section022
