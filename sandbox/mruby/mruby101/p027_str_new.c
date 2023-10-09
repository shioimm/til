// 入門mruby

#include <mruby.h>
#include <mruby/compile.h>

int main()
{
  mrb_state *mrb = mrb_open();

  const char *s1 = "str1";
  mrb_value str1 = mrb_str_new(mrb, s1, 4);
  mrb_p(mrb, str1);

  const char *s2 = "str2";
  mrb_value str2 = mrb_str_new_cstr(mrb, s2);
  mrb_p(mrb, str2);

  mrb_value str3 = mrb_str_new_lit(mrb, "str3");
  mrb_p(mrb, str3);

  mrb_close(mrb);

  return 0;
}
