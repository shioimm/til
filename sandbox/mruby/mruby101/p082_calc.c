// 入門mruby
#include <mruby.h>
#include <mruby/numeric.h>
#include <mruby/compile.h>
#include <mruby/error.h>
#include <math.h>

mrb_value body1_func(mrb_state *mrb, mrb_value arg)
{
  mrb_float flt = mrb_to_flo(mrb, arg);

  if (flt < 0) {
    mrb_raisef(mrb, E_ARGUMENT_ERROR, "out of dmain: %S", mrb_float_value(mrb, flt));
  } else {
    return mrb_float_value(mrb, flt);
  }
}

static mrb_value rescue_func(mrb_state *mrb, mrb_value arg)
{
  mrb_load_string(mrb, "puts 'Error!'");
  return arg;
}

static mrb_value ensure_func(mrb_state *mrb, mrb_value arg)
{
  mrb_load_string(mrb, "puts '... calc done.'");
  return arg;
}

mrb_value body0_func(mrb_state *mrb, mrb_value arg)
{
  mrb_load_string(mrb, "puts '...calc started...'");

  struct RClass *e_class = E_ARGUMENT_ERROR;
  mrb_value nil = mrb_nil_value();
  mrb_value val = mrb_rescue_exceptions(mrb, body1_func, arg, rescue_func, nil, 1, &e_class);

  if (mrb_test(val)) {
    mrb_p(mrb, val);
  }

  return val;
}

mrb_value calc_sqrt(mrb_state *mrb, mrb_value self)
{
  mrb_value arg;
  mrb_value nil = mrb_nil_value();

  mrb_get_args(mrb, "o", &arg);

  return mrb_ensure(mrb, body0_func, arg, ensure_func, nil);
}

int main()
{
  mrb_state *mrb = mrb_open();

  struct RClass *c = mrb_define_class(mrb, "Calc", mrb->object_class);
  mrb_define_class_method(mrb, c, "sqrt", calc_sqrt, MRB_ARGS_REQ(1));

  mrb_load_string(mrb, "Calc.sqrt(2.0)");
  mrb_load_string(mrb, "Calc.sqrt(-2.0)");

  mrb_close(mrb);

  return 0;
}

// build_config/default.rb
// conf.gem core: 'mruby-error' を追加
