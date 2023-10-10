// 入門mruby
#include <mruby.h>
#include <mruby/compile.h>
#include <mruby/class.h>

static mrb_float c2f(mrb_float deg)
{
  return (deg * 9.0 / 5.0) + 32.0;
}

static mrb_value mrb_celsius_c2f(mrb_state *mrb, mrb_value self)
{
  mrb_float deg;
  mrb_get_args(mrb, "f", &deg);

  return mrb_float_value(mrb, c2f(deg));
}

int main()
{
  mrb_state *mrb = mrb_open();

  struct RClass *celsius = mrb_define_class(mrb, "Celsius", mrb->object_class);
  mrb_define_class_method(mrb, celsius, "c2f", mrb_celsius_c2f, MRB_ARGS_REQ(1));

  mrb_value val;
  val = mrb_load_string(mrb, "Celsius.c2f(10.0)");
  mrb_p(mrb, val);

  mrb_close(mrb);

  return 0;
}
