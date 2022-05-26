#include "ws_protocol.h"

#define PROTO1_PORT 4567

static int proto_proto1 = -1;

static int dissect_proto1(tvbuff_t *tvb, packet_info *pinfo, proto_tree *tree _U_, void *data _U_)
{
  col_set_str(pinfo->cinfo, COL_PROTOCOL, "PROTO FOO");
  col_clear(pinfo->cinfo,COL_INFO);

  return tvb_captured_length(tvb);
}

// static void ws_protocol_register(mrb_state *mrb, mrb_value self)
static void ws_protocol_register(void)
{
  proto_proto1 = proto_register_protocol(
    "PROTOFOO Protocol",
    "PROTOFOO",
    "protofoo"
  );
}

// static void ws_protocol_handoff(mrb_state *mrb, mrb_value self)
static void ws_protocol_handoff(void)
{
  static dissector_handle_t proto1_handle;

  proto1_handle = create_dissector_handle(dissect_proto1, proto_proto1);
  dissector_add_uint("tcp.port", PROTO1_PORT, proto1_handle);
}

static mrb_value mrb_ws_protocol_dissect(mrb_state *mrb, mrb_value self)
{
  mrb_p(mrb, self);
  ws_protocol_register();
  ws_protocol_handoff();

  return self;
}

void mrb_ws_protocol_init(mrb_state *mrb)
{
  FILE *ws_tree_src     = fopen("../plugins/epan/proto1/ws_tree.rb", "r");
  FILE *ws_protocol_src = fopen("../plugins/epan/proto1/ws_protocol.rb", "r");
  mrb_load_file(mrb, ws_tree_src);
  mrb_load_file(mrb, ws_protocol_src);

  mrb_value      mrb_ws_protocol_klass = mrb_obj_value(mrb_class_get(mrb, "WSProtocol"));
  struct RClass *ws_protocol_klass     = mrb_class_ptr(mrb_ws_protocol_klass);

  mrb_define_method(mrb, ws_protocol_klass, "dissect!", mrb_ws_protocol_dissect, MRB_ARGS_NONE());
}
