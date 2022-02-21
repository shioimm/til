// 入門mruby
#include <mruby.h>
#include <mruby/compile.h>
#include <mruby/array.h>

int main()
{
  mrb_state *mrb = mrb_open();

  mrb_value ary = mrb_ary_new_capa(mrb, 5);

  int i;
  for (i = 0; i < 5; i++) {
    mrb_ary_push(mrb, ary, mrb_fixnum_value(i));
  }

  mrb_p(mrb, ary);

  mrb_int len = RARRAY_LEN(ary);
  mrb_value item;

  for (i = 0; i < len; i++) {
    item = mrb_ary_pop(mrb, ary);
    mrb_p(mrb, item);
  }

  mrb_p(mrb, ary);

  mrb_close(mrb);

  return 0;
}
