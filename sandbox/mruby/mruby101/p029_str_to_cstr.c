// 入門mruby

#include <mruby.h>
#include <mruby/compile.h>
#include <mruby/string.h>
#include <stdio.h>

int main()
{
  mrb_state *mrb = mrb_open();

  const char *s = "ABCD";
  mrb_value str = mrb_str_new_cstr(mrb, s);

  char *cs1 = mrb_str_to_cstr(mrb, str);
  char *ps1 = RSTRING_PTR(str);
  int  len1 = RSTRING_LEN(str);

  printf("cs1 = %s at %p\n", cs1, cs1);
  printf("ps1 = %s at %p, len = %d\n", ps1, ps1, len1);

  char *cs2 = mrb_str_to_cstr(mrb, str);
  char *ps2 = RSTRING_PTR(str);
  int  len2 = RSTRING_LEN(str);

  printf("cs2 = %s at %p\n", cs2, cs2);
  printf("ps2 = %s at %p, len = %d\n", ps2, ps2, len2);

  mrb_close(mrb);

  return 0;
}
