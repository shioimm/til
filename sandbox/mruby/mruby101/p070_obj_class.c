// 入門mruby
#include <mruby.h>
#include <stdio.h>

int main()
{
  mrb_state *mrb = mrb_open();

  mrb_value str = mrb_str_new_lit(mrb, "str");

  struct RClass *str_class = mrb_obj_class(mrb, str);
  mrb_value class_obj = mrb_obj_value(str_class);

  printf("class of object : %s\n", mrb_obj_classname(mrb, str));
  printf("class of class : %s\n", mrb_obj_classname(mrb, class_obj));

  if (mrb_obj_is_kind_of(mrb, str, mrb->string_class)) { // true
    printf("str is a kind of String\n");
  }
  if (mrb_obj_is_kind_of(mrb, str, mrb->object_class)) { // true
    printf("str is a kind of Object\n");
  }

  mrb_close(mrb);

  return 0;
}
