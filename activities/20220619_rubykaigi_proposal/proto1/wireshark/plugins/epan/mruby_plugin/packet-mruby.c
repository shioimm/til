#include "config.h"
#include <epan/packet.h>

#include <mruby.h>
#include <mruby/compile.h>
#include "packet-mruby.h"

void proto_register_mruby(void)
{
}

void proto_reg_handoff_mruby(void)
{
  mrb_state *mrb = mrb_open();

  mrb_plugin_gem_init(mrb);
  FILE *plugin_src = fopen("../plugins/epan/mruby_plugin/plugin.rb", "r");
  mrb_load_file(mrb, plugin_src);

  mrb_close(mrb);
}
