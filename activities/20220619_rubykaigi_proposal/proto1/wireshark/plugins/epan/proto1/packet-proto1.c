#include "config.h"
#include <epan/packet.h>

#include <mruby.h>
#include <mruby/compile.h>
#include "ws_protocol.c"

void proto_register_proto1(void)
{
}

void proto_reg_handoff_proto1(void)
{
  mrb_state *mrb = mrb_open();

  mrb_plugin_gem_init(mrb);
  // FILE *plugin_src = fopen("../plugins/epan/proto1/config.foo.rb", "r");
  // mrb_load_file(mrb, plugin_src);
  register_protocol_proto1();
  register_handoff_proto1();

  mrb_close(mrb);
}
