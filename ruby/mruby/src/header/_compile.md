# `#include <mruby/compile.h>`
#### `mrb_define_class`
- 文字列`s`をRubyスクリプトとしてmruby VMに読み込ませる

```c
MRB_API mrb_value
mrb_load_string(mrb_state *mrb, const char *s);
```

## 参照
- Webで使えるmrubyシステムプログラミング入門 section033
