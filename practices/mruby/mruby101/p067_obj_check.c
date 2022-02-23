// 入門mruby
#include <mruby.h>
#include <stdio.h>

int main()
{
  mrb_state *mrb = mrb_open();

  mrb_value str = mrb_str_new_lit(mrb, "S");
  printf("mrb_string_p: %d ", mrb_string_p(str));
  mrb_p(mrb, mrb_bool_value(mrb_string_p(str)));
  printf("mrb_hash_p:   %d ", mrb_hash_p(str));
  mrb_p(mrb, mrb_bool_value(mrb_hash_p(str)));
  printf("mrb_nil_p:    %d ", mrb_nil_p(mrb_nil_value()));
  mrb_p(mrb, mrb_bool_value(mrb_hash_p(str)));
  printf("mrb_true_p:   %d ", mrb_true_p(mrb_true_value()));
  mrb_p(mrb, mrb_bool_value(mrb_true_p(mrb_true_value())));
  printf("mrb_test:     %d ", mrb_test(mrb_fixnum_value(1)));
  mrb_p(mrb, mrb_bool_value(mrb_test(mrb_fixnum_value(1))));
  printf("mrb_test:     %d ", mrb_test(mrb_false_value()));
  mrb_p(mrb, mrb_bool_value(mrb_test(mrb_false_value())));

  mrb_close(mrb);

  return 0;
}
