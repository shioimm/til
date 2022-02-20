# C用ファイルテンプレート
- `src/mrb_mgemの名前.c`

```c
#include "mruby.h"
#include "mruby/data.h"
#include "mrb_mgemの名前.h"

# Cでのmrubyメソッド定義の際に中間的に作られるmrubyオブジェクトを
# 効率よく回収するための関数マクロ
#define DONE mrb_gc_arena_restore(mrb, 0);

typedef struct {
  char *str;
  mrb_int len;
} mrb_mgemの名前_data;

static const struct mrb_data_type mrb_mgemの名前_data_type = {
  "mrb_mgemの名前_data", mrb_free,
};

static mrb_value mrb_mgemの名前_init(mrb_state *mrb, mrb_value self)
{
  mrb_mgemの名前_data *data;
  char *str;
  mrb_int len;

  data = (mrb_mgemの名前_data *)DATA_PTR(self);
  if (data) {
    mrb_free(mrb, data);
  }
  DATA_TYPE(self) = &mrb_mgemの名前_data_type;
  DATA_PTR(self) = NULL;

  mrb_get_args(mrb, "s", &str, &len);
  data = (mrb_mgemの名前_data *)mrb_malloc(mrb, sizeof(mrb_mgemの名前_data));
  data->str = str;
  data->len = len;
  DATA_PTR(self) = data;

  return self;
}

static mrb_value mrb_mgemの名前_hello(mrb_state *mrb, mrb_value self)
{
  mrb_mgemの名前_data *data = DATA_PTR(self);

  return mrb_str_new(mrb, data->str, data->len);
}

static mrb_value mrb_mgemの名前_hi(mrb_state *mrb, mrb_value self)
{
  return mrb_str_new_cstr(mrb, "hi!!");
}

# mgemの読み込み時に最初に呼ばれる関数
void mrb_mgemの名前_gem_init(mrb_state *mrb)
{
  struct RClass *mgemの名前;
  mgemの名前 = mrb_define_class(mrb, "Example", mrb->object_class);
  mrb_define_method(mrb, mgemの名前, "initialize", mrb_mgemの名前_init, MRB_ARGS_REQ(1));
  mrb_define_method(mrb, mgemの名前, "hello", mrb_mgemの名前_hello, MRB_ARGS_NONE());
  mrb_define_class_method(mrb, mgemの名前, "hi", mrb_mgemの名前_hi, MRB_ARGS_NONE());
  DONE;
}

# mgemの終了時に呼ばれる関数
void mrb_mgemの名前_gem_final(mrb_state *mrb)
{
}
```

## 参照
- [mruby-mrbgem-template](https://github.com/matsumotory/mruby-mrbgem-template)
- Webで使えるmrubyシステムプログラミング入門 Section019
