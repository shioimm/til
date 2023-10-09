// 入門mruby

#include <mruby.h>
#include <mruby/compile.h>
#include <mruby/string.h>

int main()
{
  mrb_state *mrb = mrb_open();

  mrb_value str = mrb_str_new_lit(mrb, "str");

  const char *s1 = "s1";
  mrb_str_cat(mrb, str, s1, 2);

  const char *s2 = "s2";
  mrb_str_cat_cstr(mrb, str, s2);

  mrb_str_cat_lit(mrb, str, "s3");

  mrb_value s4 = mrb_str_new_lit(mrb, "s4");
  mrb_str_cat_str(mrb, str, s4);

  mrb_p(mrb, str);

  mrb_close(mrb);

  return 0;
}
