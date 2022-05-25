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

  mrb_ws_protocol_init(mrb);

  FILE *config_src = fopen("../plugins/epan/proto1/config.foo.rb", "r");
  mrb_load_file(mrb, config_src);

  mrb_close(mrb);
}
