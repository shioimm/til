// 入門mruby
#include <mruby.h>
#include <mruby/compile.h>
#include <mruby/numeric.h>

int main()
{
  mrb_value val;
  mrb_state *mrb = mrb_open();

  mrb_float f1 = 4.56;
  mrb_value f2 = mrb_float_value(mrb, f1);

  val = mrb_flo_to_fixnum(mrb, f2);

  mrb_p(mrb, val);

  mrb_close(mrb);

  return 0;
}
