# `#include <mruby/compile.h>`
#### `mrb_load_string`
- 文字列`s`をRubyスクリプトとしてパースし、バイトコードへ変換し、mruby VM上で実行して結果を返す

```c
MRB_API mrb_value
mrb_load_string(mrb_state *mrb, const char *s);
```

## 参照
- Webで使えるmrubyシステムプログラミング入門 section033
