// 入門mruby
#include <mruby.h>
#include <mruby/compile.h>
#include <mruby/array.h>

int main()
{
  mrb_state *mrb = mrb_open();

  // 要素の分のメモリを確保し、valsの参照先の値を確保したメモリにコピーする
  const mrb_value vals[] = { mrb_fixnum_value(42), mrb_true_value() };

  mrb_value ary = mrb_ary_new_from_values(mrb, 2, vals);
  mrb_p(mrb, ary);

  mrb_close(mrb);

  return 0;
}
