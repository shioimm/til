// 入門mruby
#include <mruby.h>
#include <mruby/compile.h>
#include <mruby/numeric.h>

int main()
{
  mrb_state *mrb = mrb_open();

  mrb_value x;
  mrb_value n1 = mrb_int_value(mrb, 12);
  mrb_value n2 = mrb_int_value(mrb, 34);

  x = mrb_num_plus(mrb, n1, n2);
  mrb_p(mrb, x);

  mrb_float y;
  mrb_float n3 = 12.0;
  mrb_float n4 = 34.0;

  y = mrb_div_float(n3, n4);
  x = mrb_float_value(mrb, y);
  mrb_p(mrb, x);

  mrb_close(mrb);

  return 0;
}
