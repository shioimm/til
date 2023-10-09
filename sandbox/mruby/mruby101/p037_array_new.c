// 入門mruby
#include <mruby.h>
#include <mruby/compile.h>
#include <mruby/array.h>

int main()
{
  mrb_state *mrb = mrb_open();

  mrb_value ary = mrb_ary_new_capa(mrb, 10);
  mrb_p(mrb, ary);

  mrb_ary_set(mrb, ary, 0, mrb_fixnum_value(42));
  mrb_ary_set(mrb, ary, 1, mrb_true_value());
  mrb_p(mrb, ary);

  mrb_close(mrb);

  return 0;
}
