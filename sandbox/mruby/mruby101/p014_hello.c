// 入門mruby
#include <mruby.h>
#include <mruby/compile.h>

int main()
{
  mrb_state *mrb = mrb_open();
  mrb_load_string(mrb, "p 'Hello mruby'");
  mrb_close(mrb);

  return 0;
}
