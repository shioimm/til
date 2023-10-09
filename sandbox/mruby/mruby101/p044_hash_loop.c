// 入門mruby
#include <mruby.h>
#include <mruby/compile.h>
#include <mruby/hash.h>

int hash_foreach_func(mrb_state *mrb, mrb_value key, mrb_value val, void *data)
{
  mrb_p(mrb, key);
  mrb_p(mrb, val);

  return 0;
}

int main()
{
  mrb_state *mrb = mrb_open();

  mrb_value hash = mrb_hash_new_capa(mrb, 10);

  mrb_sym sym1 = mrb_intern_lit(mrb, "num");
  mrb_hash_set(mrb, hash, mrb_symbol_value(sym1), mrb_fixnum_value(42));

  mrb_sym sym2 = mrb_intern_lit(mrb, "bool");
  mrb_hash_set(mrb, hash, mrb_symbol_value(sym2), mrb_true_value());

  mrb_p(mrb, hash);

  mrb_hash_foreach(mrb, RHASH(hash), hash_foreach_func, NULL);

  mrb_close(mrb);

  return 0;
}
