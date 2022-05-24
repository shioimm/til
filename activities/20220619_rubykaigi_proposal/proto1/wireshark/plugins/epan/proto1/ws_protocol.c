#include "config.h"
#include <epan/packet.h>

#include <stdlib.h>
#include <string.h>

#include <mruby.h>
#include <mruby/class.h>
#include <mruby/compile.h>
#include <mruby/numeric.h>
#include <mruby/string.h>
#include <mruby/value.h>
#include <mruby/variable.h>

#define PROTO1_PORT 4567

static int proto_proto1 = -1;

static int dissect_proto1(tvbuff_t *tvb, packet_info *pinfo, proto_tree *tree _U_, void *data _U_)
{
  col_set_str(pinfo->cinfo, COL_PROTOCOL, "PROTO FOO");
  col_clear(pinfo->cinfo,COL_INFO);

  return tvb_captured_length(tvb);
}

void register_protocol_proto1(void)
{
  proto_proto1 = proto_register_protocol(
    "PROTOFOO Protocol",
    "PROTOFOO",
    "protofoo"
  );
}

void register_handoff_proto1(void)
{
  static dissector_handle_t proto1_handle;

  proto1_handle = create_dissector_handle(dissect_proto1, proto_proto1);
  dissector_add_uint("tcp.port", PROTO1_PORT, proto1_handle);
}

void mrb_plugin_gem_init(mrb_state *mrb)
{
  FILE *ws_tree_src     = fopen("../plugins/epan/proto1/ws_tree.rb", "r");
  FILE *ws_protocol_src = fopen("../plugins/epan/proto1/ws_protocol.rb", "r");

  mrb_load_file(mrb, ws_tree_src);
  mrb_load_file(mrb, ws_protocol_src);
}
