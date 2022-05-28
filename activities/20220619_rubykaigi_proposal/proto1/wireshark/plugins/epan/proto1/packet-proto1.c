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

  ws_protocol_start(mrb, "../plugins/epan/proto1/config.foo.rb");

  mrb_close(mrb);
}
