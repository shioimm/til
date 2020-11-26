# `#include <mruby/error.h>`
- 参照: Webで使えるmrubyシステムプログラミング入門 Section019

## `mrb_sys_fail`
```c
MRB_API void mrb_sys_fail(mrb_state  *mrb,
                          const char *mesg);
```
- システムに関わるエラーを例外として上げる

## `mrb_raise`
```c
MRB_API mrb_noreturn void mrb_raise(mrb_state     *mrb,
                                    struct RClass *c,
                                    const char    *msg);
```
- mrubyの例外を上げる
