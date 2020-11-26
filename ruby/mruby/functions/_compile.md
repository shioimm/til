# `#include <mruby/compile.h>`
- 参照: webで使えるmrubyシステムプログラミング入門 section033

## `mrb_define_class`
```c
MRB_API mrb_value mrb_load_string(mrb_state  *mrb,
                                  const char *s);
```
- 文字列`s`をRubyスクリプトとしてmruby VMに読み込ませる
