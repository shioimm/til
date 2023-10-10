// 入門mruby
#include <mruby.h>
#include <mruby/compile.h>

// ブロック内で行う処理
mrb_value func_block(mrb_state *mrb, mrb_value self)
{
  mrb_int num;
  mrb_value blk;
  mrb_get_args(mrb, "i&", &num, &blk);

  mrb_sym times = mrb_intern_lit(mrb, "times");

  return mrb_funcall_with_block(mrb, mrb_fixnum_value(num), times, 0, NULL, blk);
}

int main()
{
  mrb_state *mrb = mrb_open();

  // Kernelモジュールに定義
  mrb_define_method(mrb, mrb->kernel_module, "funcall", func_block, MRB_ARGS_BLOCK());

  mrb_load_string(mrb, "funcall(3) { p 'Hi' }");

  mrb_close(mrb);

  return 0;
}
