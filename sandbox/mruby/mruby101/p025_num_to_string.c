// 入門mruby
#include <mruby.h>
#include <mruby/numeric.h>

int main()
{
  mrb_state *mrb = mrb_open();

  mrb_int   i1 = 123;
  mrb_value n1 = mrb_fixnum_value(i1);

  mrb_value s1 = mrb_fixnum_to_str(mrb, n1, 10);
  mrb_p(mrb, s1);

  mrb_float f1 = 4.56;
  mrb_value n2 = mrb_float_value(mrb, f1);

  mrb_value s2 = mrb_float_to_str(mrb, n2, "%1.1f");;
  mrb_p(mrb, s2);

  mrb_close(mrb);

  return 0;
}
