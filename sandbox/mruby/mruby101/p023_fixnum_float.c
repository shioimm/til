// 入門mruby
#include <mruby.h>
#include <mruby/compile.h>
#include <stdio.h>

int main()
{
  mrb_state *mrb = mrb_open();

  mrb_value n1 = mrb_fixnum_value(12);
  mrb_int   i1 = mrb_fixnum(n1);

  mrb_value n2 = mrb_float_value(mrb, 3.4);
  mrb_float f1 = mrb_float(n2);

  printf("i1 = %lld, f1 = %f\n", i1, f1);

  mrb_close(mrb);

  return 0;
}
