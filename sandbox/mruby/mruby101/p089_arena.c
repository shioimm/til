#include <mruby.h>

mrb_value mk_str(mrb_state *mrb, mrb_int n)
{
  char buf[256];

  snprintf(buf, sizeof(buf), "string-%lld", n);

  return mrb_str_new_cstr(mrb, buf);
}

// GC arenaの節約を行う
int main()
{
  mrb_state *mrb = mrb_open();

  int arena_idx = mrb_gc_arena_save(mrb); // arenaのインデックスを保存

  for (mrb_int i = 0; i <= 120; i++) {
    mrb_value val = mk_str(mrb, i);
    mrb_p(mrb, val);
    mrb_gc_arena_restore(mrb, arena_idx); // 保存したインデックスを復元
  }

  mrb_close(mrb);

  return 0;
}
