# `#include <mruby/string.h>`
#### `mrb_str_new`
- 列の長さがあらかじめわかっているC文字列またはバイナリ列をStringオブジェクトへ変換する

```c
MRB_API mrb_value
mrb_str_new(mrb_state *mrb, const char *p, size_t len);
```

#### `mrb_str_new_cstr`
- `\0`で終端されているC文字列をStringオブジェクトへ変換する

```c
MRB_API mrb_value
mrb_str_new_cstr(mrb_state *mrb, const char *p);
```

#### `mrb_str_new_lit`
- C文字列リテラルをStringオブジェクトへ変換する

```
MRB_API mrb_value
mrb_str_new_lit(mrb_state *mrb, const char *p)
```

#### `mrb_string_cstr`
- StringオブジェクトをC文字列`char *`型へ変換する
  - Stringオブジェクトを必要に応じて作り直してC文字列を取り出す


```c
MRB_API const char*
mrb_string_cstr(mrb_state *mrb, mrb_value str);
```

#### `RSTRING_PTR` (マクロ)
- Stringオブジェクト内のC文字列を直接参照する

```c
char *RSTRING_PTR(mrb_value str)
```

#### `RSTRING_LEN` (マクロ)
- Stringオブジェクト内のC文字列の長さを得る


```c
mrb_int RSTRING_LEN(mrb_value str)
```

## 参照
- Webで使えるmrubyシステムプログラミング入門 Section019
