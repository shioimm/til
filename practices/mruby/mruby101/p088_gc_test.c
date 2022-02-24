#include <mruby.h>
#include <mruby/compile.h>

int main()
{
  mrb_state *mrb = mrb_open();

  mrb_load_string(mrb, "puts 'gc disabled'");
  mrb->gc.disabled = TRUE; // GCを止める

  mrb_full_gc(mrb); // GCされない

  mrb_load_string(mrb, "puts 'gc enabled'");
  mrb->gc.disabled = FALSE; // GCを許可する

  mrb_full_gc(mrb); // GCされる

  mrb_close(mrb);

  return 0;
}
