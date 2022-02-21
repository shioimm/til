// 入門mruby
#include <mruby.h>
#include <mruby/compile.h>
#include <mruby/array.h>
#include <mruby/hash.h>

int main()
{
  mrb_state *mrb = mrb_open();

  mrb_value hash = mrb_hash_new_capa(mrb, 10);
  mrb_p(mrb, hash);

  mrb_sym sym1 = mrb_intern_lit(mrb, "num");
  mrb_hash_set(mrb, hash, mrb_symbol_value(sym1), mrb_fixnum_value(42));

  mrb_sym sym2 = mrb_intern_lit(mrb, "bool");
  mrb_hash_set(mrb, hash, mrb_symbol_value(sym2), mrb_true_value());

  mrb_p(mrb, hash);

  mrb_value keys = mrb_hash_keys(mrb, hash);
  mrb_int len = RARRAY_LEN(keys);
  mrb_value item;
  mrb_int i;

  for (i = 0; i < len; i++) {
    mrb_value key = mrb_ary_ref(mrb, keys, i);
    mrb_p(mrb, key);
    item = mrb_hash_get(mrb, hash, key);
    mrb_p(mrb, item);
  }
  mrb_p(mrb, keys);

  mrb_close(mrb);

  return 0;
}
