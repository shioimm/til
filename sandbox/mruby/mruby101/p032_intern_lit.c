// 入門mruby

#include <mruby.h>
#include <mruby/compile.h>
#include <mruby/string.h>
#include <stdio.h>

int main()
{
  mrb_state *mrb = mrb_open();

  mrb_sym   sym1 = mrb_intern_lit(mrb, "ABCD"); // mrb_sym型
  mrb_value val  = mrb_symbol_value(sym1); // mrb_sym型 -> Symbolオブジェクト
  mrb_p(mrb, val);
  printf("sym1 = %d\n", sym1);

  mrb_sym    sym2 = mrb_symbol(val); // Symbolオブジェクト -> mrb_sym型
  const char *str = mrb_sym2name(mrb, sym2); // mrb_sym型 -> C文字列
  printf("sym2 = %d\n", sym2);
  printf("name = %s\n", str);

  mrb_close(mrb);

  return 0;
}
