// 入門mruby
#include <mruby.h>
#include <mruby/compile.h>
#include <mruby/class.h>
#include <stdio.h>

int main()
{
  mrb_state *mrb = mrb_open();

  struct RClass *foo_class = mrb_define_class(mrb, "Foo", mrb->object_class);
  struct RClass *buz_mod   = mrb_define_module(mrb, "Buz");

  mrb_include_module(mrb, foo_class, buz_mod);

  mrb_value foo_value = mrb_obj_value(mrb_class_get(mrb, "Foo"));
  mrb_value buz_value = mrb_obj_value(mrb_module_get(mrb, "Buz"));

  mrb_value val = mrb_funcall(mrb, foo_value, "include?", 1, buz_value);

  mrb_p(mrb, val);

  mrb_close(mrb);

  return 0;
}
