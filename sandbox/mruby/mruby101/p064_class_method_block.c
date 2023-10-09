// 入門mruby
#include <mruby.h>
#include <mruby/compile.h>
#include <mruby/array.h>
#include <mruby/numeric.h>

static mrb_float c2f(mrb_float deg)
{
  return (deg * 9.0 / 5.0) + 32.0;
}

static mrb_value mrb_celsius_c2f_block(mrb_state *mrb, mrb_value self)
{
  mrb_value degs;
  mrb_value blk;

  mrb_get_args(mrb, "A&", &degs, &blk);

  mrb_int len = RARRAY_LEN(degs);

  for (mrb_int i = 0; i < len; i++) {
    mrb_value val = mrb_ary_ref(mrb, degs, i);

    if (!mrb_float_p(val)) {
      mrb_raisef(mrb, E_TYPE_ERROR, "%v is not a Float", val);
    }

    mrb_float f = c2f(mrb_float(val));
    mrb_yield(mrb, blk, mrb_float_value(mrb, f));
  }

  return mrb_nil_value();
}

int main()
{
  mrb_state *mrb = mrb_open();

  struct RClass *celsius = mrb_define_class(mrb, "Celsius", mrb->object_class);

  mrb_define_class_method(mrb, celsius, "each_c2f", mrb_celsius_c2f_block, MRB_ARGS_REQ(1));

  mrb_load_string(mrb, "Celsius.each_c2f([10.0, 11.0, 12.0]) { |f| puts f }");

  mrb_close(mrb);

  return 0;
}
