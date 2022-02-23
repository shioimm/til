// 入門mruby
#include <mruby.h>
#include <mruby/compile.h>
#include <mruby/class.h>
#include <stdio.h>

int main()
{
  mrb_state *mrb = mrb_open();

  struct RClass *foo_class = mrb_define_class(mrb, "Foo", mrb->object_class);
  struct RClass *bar_class = mrb_define_class(mrb, "Bar", foo_class);
  struct RClass *buz_mod   = mrb_define_module(mrb, "Buz");

  printf("class 1 = %s\n", mrb_class_name(mrb, foo_class));
  printf("class 2 = %s\n", mrb_class_name(mrb, bar_class));
  printf("module  = %s\n", mrb_class_name(mrb, buz_mod));

  mrb_close(mrb);

  return 0;
}
