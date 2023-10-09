// 入門mruby
#include <mruby.h>
#include <mruby/compile.h>
#include <mruby/class.h>
#include <stdio.h>

void define_foo_buz(mrb_state *mrb)
{
  struct RClass *foo_class = mrb_define_class(mrb, "Greeting", mrb->object_class);
  mrb_define_module_under(mrb, foo_class, "Hello");

  // class Greeting
  //   module Hello
  //   end
  // end

  return;
}

int main()
{
  mrb_state *mrb = mrb_open();

  define_foo_buz(mrb);

  struct RClass *parent_class = mrb_class_get(mrb, "Greeting");
  struct RClass *child_module = mrb_module_get_under(mrb, parent_class, "Hello");
  struct RClass *grand_child_class = mrb_define_class_under(mrb, child_module, "World", mrb->object_class);

  printf("name = %s\n", mrb_class_name(mrb, grand_child_class));

  mrb_close(mrb);

  return 0;
}
