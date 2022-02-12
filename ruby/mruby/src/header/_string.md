# `#include <mruby/error.h>`
#### `mrb_str_new_cstr`
- C言語の文字列からRubyのStringオブジェクトを作る

```c
MRB_API mrb_value
mrb_str_new_cstr(mrb_state *mrb, const char *p);
```

#### `mrb_str_new`
- C言語の文字またはバイナリ列から長さを指定してRubyのStringオブジェクトを作る

```c
MRB_API mrb_value
mrb_str_new(mrb_state *mrb, const char *p, size_t len);
```

#### `mrb_string_cstr`
- RubyのStringクラスの`mrb_value`をC言語の文字列`char *`型に変換する

```c
MRB_API const char*
mrb_string_cstr(mrb_state *mrb, mrb_value  str);
```

## 参照
- Webで使えるmrubyシステムプログラミング入門 Section019
