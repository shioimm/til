// 入門mruby
#include <mruby.h>
#include <mruby/compile.h>
#include <mruby/array.h>

int main()
{
  mrb_value val;
  mrb_state *mrb = mrb_open();

  mrb_value num1 = mrb_fixnum_value(12);
  mrb_value num2 = mrb_fixnum_value(34);

  val = mrb_funcall(mrb, num1, "+", 1, num2);
  mrb_p(mrb, val);

  mrb_sym sym_mul = mrb_intern_cstr(mrb, "*");
  const mrb_value argv[] = { num2 };

  val = mrb_funcall_argv(mrb, num1, sym_mul, 1, argv);
  mrb_p(mrb, val);

  mrb_close(mrb);

  return 0;
}
