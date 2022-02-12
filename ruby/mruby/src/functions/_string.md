# `#include <mruby/error.h>`
- 参照: Webで使えるmrubyシステムプログラミング入門 Section019

## `mrb_str_new_cstr`
```c
MRB_API mrb_value mrb_str_new_cstr(mrb_state  *mrb,
                                   const char *p);
```
- C言語の文字列からRubyのStringオブジェクトを作る

## `mrb_str_new`
```c
MRB_API mrb_value mrb_str_new(mrb_state  *mrb,
                              const char *p,
                              size_t      len);
```
- C言語の文字またはバイナリ列から長さを指定してRubyのStringオブジェクトを作る

## `mrb_string_cstr`
```c
MRB_API const char* mrb_string_cstr(mrb_state *mrb,
                                    mrb_value  str);
```
- RubyのStringクラスの`mrb_value`をC言語の文字列`char *`型に変換する
