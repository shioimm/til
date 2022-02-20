# `#include <mruby/error.h>`
#### `mrb_sys_fail`
- システムに関わるエラーを例外として上げる

```c
MRB_API void
mrb_sys_fail(mrb_state *mrb, const char *mesg);
```

#### `mrb_raise`
- mrubyの例外を上げる

```c
MRB_API mrb_noreturn void
mrb_raise(mrb_state *mrb, struct RClass *c, const char *msg);
```

## 参照
- Webで使えるmrubyシステムプログラミング入門 Section019
