// 入門mruby
#include <mruby.h>
#include <mruby/compile.h>
#include <mruby/class.h>
#include <mruby/variable.h>

int main()
{
  mrb_state *mrb = mrb_open();

  struct RClass *foo_class = mrb_define_class(mrb, "Foo", mrb->object_class);
  struct RClass *bar_class = mrb_define_class(mrb, "Bar", foo_class);

  mrb_sym const_foo = mrb_intern_lit(mrb, "FOO");
  mrb_const_set(mrb, mrb_obj_value(mrb->object_class), const_foo, mrb_fixnum_value(42));
  mrb_const_set(mrb, mrb_obj_value(bar_class), const_foo, mrb_fixnum_value(84));

  // FOO = 42
  // class Foo; end
  // class Bar < Foo
  //   FOO = 84
  // end

  mrb_value foo1 = mrb_const_get(mrb, mrb_obj_value(mrb->object_class), const_foo);
  mrb_value foo2 = mrb_const_get(mrb, mrb_obj_value(foo_class), const_foo);
  mrb_value foo3 = mrb_const_get(mrb, mrb_obj_value(bar_class), const_foo);

  printf("FOO      = %d\n", mrb_fixnum(foo1)); // 42
  printf("Foo::FOO = %d\n", mrb_fixnum(foo2)); // 42
  printf("Bar::FOO = %d\n", mrb_fixnum(foo3)); // 84

  mrb_close(mrb);
  return 0;
}
