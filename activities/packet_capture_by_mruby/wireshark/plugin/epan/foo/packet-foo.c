#include "config.h"
#include <epan/packet.h>

#include <mruby.h>
#include <mruby/compile.h>
#include "packet-foo.h"

#define FOO_PORT 30000

void proto_register_foo(void)
{
}

void proto_reg_handoff_foo(void)
{
  mrb_state *mrb = mrb_open();

  mrb_plugin_gem_init(mrb);
  mrbc_context *cxt = mrbc_context_new(mrb);
  mrb_load_string_cxt(mrb, "plugin = Plugin.new('FOO', :tcp, 30000)", cxt);
  mrb_load_string_cxt(mrb, "plugin.enable", cxt);

  mrb_close(mrb);
}

