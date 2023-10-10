// 入門mruby
#include <mruby.h>
#include <mruby/compile.h>
#include <mruby/class.h>
#include <mruby/variable.h>
#include <mruby/string.h>

static mrb_value mrb_foo_get_name(mrb_state *mrb, mrb_value self)
{
  mrb_value name = mrb_iv_get(mrb, self, mrb_intern_lit(mrb, "@name"));

  return name;
}

static mrb_value mrb_foo_set_name(mrb_state *mrb, mrb_value self)
{
  mrb_value obj;
  mrb_get_args(mrb, "o", &obj);
  mrb_iv_set(mrb, self, mrb_intern_lit(mrb, "@name"), obj);

  return self;
}

int main()
{
  mrb_state *mrb = mrb_open();

  struct RClass *foo_class = mrb_define_class(mrb, "Foo", mrb->object_class);
  mrb_define_method(mrb, foo_class, "name",  mrb_foo_get_name, MRB_ARGS_NONE());
  mrb_define_method(mrb, foo_class, "name=", mrb_foo_set_name, MRB_ARGS_REQ(1));

  mrb_load_string(mrb, "foo = Foo.new\nfoo.name='foo_name'\nputs \"name is #{foo.name}\"");

  mrb_close(mrb);
  return 0;
}
