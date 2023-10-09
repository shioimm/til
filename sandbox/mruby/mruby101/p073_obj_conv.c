// 入門mruby
#include <mruby.h>
#include <mruby/array.h>
#include <mruby/hash.h>
#include <mruby/string.h>
#include <mruby/class.h>
#include <stdio.h>

int main()
{
  mrb_state *mrb = mrb_open();

  mrb_value str = mrb_str_new_lit(mrb, "str");
  struct RString *rstr = mrb_str_ptr(str); // mrb_value "str" -> RString
  mrb_p(mrb, mrb_obj_value(rstr)); // RString -> mrb_value "str"

  const mrb_value vals[] = { str };
  mrb_value ary = mrb_ary_new_from_values(mrb, 1, vals);
  struct RArray *rary = mrb_ary_ptr(ary); // mrb_value ["str"] -> RArray
  mrb_p(mrb, mrb_obj_value(rary)); // RArray -> mrb_value ["str"]

  mrb_value hsh = mrb_hash_new(mrb);
  mrb_hash_set(mrb, hsh, str, mrb_fixnum_value(42));
  struct RHash *rhsh = mrb_hash_ptr(hsh); // mrb_value {"str"=>42} -> RHash
  mrb_p(mrb, mrb_obj_value(rhsh)); // RHash -> mrb_value {"str"=>42}

  mrb_value cls = mrb_obj_value(mrb->object_class);
  struct RClass *rcls = mrb_class_ptr(cls); // mrb_value Object -> RClass
  mrb_p(mrb, mrb_obj_value(rcls)); // RClass -> mrb_value Object

  mrb_close(mrb);

  return 0;
}
