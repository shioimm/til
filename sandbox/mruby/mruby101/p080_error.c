// 入門mruby
#include <mruby.h>
#include <mruby/compile.h>
#include <stdio.h>

int main()
{
  mrb_state *mrb = mrb_open();

  mrbc_context *cxt = mrbc_context_new(mrb);

  mrb_value val;

  val = mrb_load_string_cxt(mrb, "a = 1 + 2", cxt);
  mrb_p(mrb, val);

  val = mrb_load_string_cxt(mrb, "a1", cxt);

  if (mrb->exc) {
    printf("got error: tt = %d, class = %s\n", mrb->exc->tt, mrb_class_name(mrb, mrb->exc->c));
  } else {
    mrb_p(mrb, val);
  }

  mrb_close(mrb);

  return 0;
}
