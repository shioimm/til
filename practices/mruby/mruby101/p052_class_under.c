// 入門mruby
#include <mruby.h>
#include <mruby/compile.h>
#include <mruby/class.h>
#include <stdio.h>

// class Foo
//   module Buz
//     class Bar
//     end
//   end
// end

int main()
{
  mrb_state *mrb = mrb_open();

  struct RClass *foo_class = mrb_define_class(mrb, "Foo", mrb->object_class);
  struct RClass *buz_mod   = mrb_define_module_under(mrb, foo_class, "Buz");
  struct RClass *bar_class = mrb_define_class_under(mrb, buz_mod, "Bar", mrb->object_class);

  printf("foo_class = %s\n", mrb_class_name(mrb, foo_class)); // Foo

  struct RClass *module1 = mrb_module_get_under(mrb, foo_class, "Buz");
  printf("buz_mod   = %s\n", mrb_class_name(mrb, module1)); // Foo::Buz

  struct RClass *module2 = mrb_class_get_under(mrb, module1, "Bar");
  printf("bar_class = %s\n", mrb_class_name(mrb, module2)); // Foo::Buz::Bar

  mrb_close(mrb);

  return 0;
}
