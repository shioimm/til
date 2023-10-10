// 入門mruby

#include <mruby.h>
#include <mruby/compile.h>
#include <mruby/string.h>
#include <stdio.h>

int main()
{
  mrb_state *mrb = mrb_open();

  const char *s = "ABCD";

  mrb_sym sym1 = mrb_intern(mrb, s, 4);
  mrb_p(mrb, mrb_symbol_value(sym1));
  printf("sym1 = %d\n", sym1);

  mrb_sym sym2 = mrb_intern_cstr(mrb, s);
  mrb_p(mrb, mrb_symbol_value(sym2));
  printf("sym2 = %d\n", sym2);

  mrb_sym sym3 = mrb_intern_lit(mrb, "ABCD");
  mrb_p(mrb, mrb_symbol_value(sym3));
  printf("sym2 = %d\n", sym3);

  mrb_close(mrb);

  return 0;
}
