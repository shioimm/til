// 入門mruby
#include <mruby.h>
#include <mruby/compile.h>

int main()
{
  mrb_value val;
  mrb_state *mrb = mrb_open();

  mrb_int n = 123;
  val = mrb_fixnum_value(n);
  mrb_p(mrb, val);

  mrb_float x = 4.56;
  val = mrb_float_value(mrb, x);
  mrb_p(mrb, val);

  mrb_close(mrb);
  return 0;
}
