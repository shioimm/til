# `#include <mruby/value.h>`
- 参照: Webで使えるmrubyシステムプログラミング入門 Section022

## `mrb_bool_value`
```c
MRB_INLINE mrb_value mrb_bool_value(mrb_bool boolean)
```
- ブール値をRubyのtrue / falseへ変換する

## `mrb_true_value`
```c
MRB_INLINE mrb_value mrb_true_value()
```
- Rubyのtrueを返す

## `mrb_false_value`
```c
MRB_INLINE mrb_value mrb_false_value()
```
- Rubyのfalseを返す

## `mrb_nil_value`
```c
MRB_INLINE mrb_value mrb_nil_value()
```
- Rubyのnilを返す

## `mrb_obj_value`
```c
MRB_INLINE mrb_value mrb_obj_value(void *p)
```
- Rubyレベルの内部型を`mrb_value`型へ変換する
