#include <mruby.h>
#include <mruby/variable.h>
#include <mruby/string.h>

const char *PUNCT_MARK[] = { "!", "?", ":)" };
const int PUNCT_SIZE = sizeof(PUNCT_MARK) / sizeof(char*);

static mrb_value mrb_mruby_hello_initialize(mrb_state *mrb, mrb_value self)
{
  mrb_int   n;
  mrb_value name;

  mrb_get_args(mrb, "Si", &name, &n);

  if (n < 0 || n >= PUNCT_SIZE) {
    mrb_raisef(mrb, E_ARGUMENT_ERROR, "invalid argument.");
  }

  mrb_iv_set(mrb, self, mrb_intern_lit(mrb, "@name"), name);
  mrb_iv_set(mrb, self, mrb_intern_lit(mrb, "@num"),  mrb_fixnum_value(n));

  return self;
}

static mrb_value mrb_mruby_greeting(mrb_state *mrb, mrb_value self)
{
  mrb_value name  = mrb_iv_get(mrb, self, mrb_intern_lit(mrb, "@name"));
  mrb_int   n     = mrb_fixnum(mrb_iv_get(mrb, self, mrb_intern_lit(mrb, "@num")));
  mrb_value hello = mrb_str_new_lit(mrb, "Hello, ");

  mrb_str_cat_str(mrb, hello, name);
  mrb_str_cat_str(mrb, hello, mrb_str_new_cstr(mrb, PUNCT_MARK[n]));

  return hello;
}

void mrb_mruby_hello2_gem_init(mrb_state *mrb)
{
  struct RClass *hello_klass = mrb_define_class(mrb, "Hello", mrb->object_class);
  mrb_define_method(mrb, hello_klass, "initialize", mrb_mruby_hello_initialize, MRB_ARGS_REQ(2));
  mrb_define_method(mrb, hello_klass, "greeting",   mrb_mruby_greeting,         MRB_ARGS_NONE());
}

void mrb_mruby_hello2_gem_final(mrb_state *mrb)
{
}
