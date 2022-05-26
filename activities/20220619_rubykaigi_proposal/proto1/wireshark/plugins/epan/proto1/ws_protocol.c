#include "ws_protocol.h"

#define PROTO1_PORT 4567

char config_src_path[256];
static int phandle = -1;

static int dissect_proto1(tvbuff_t *tvb, packet_info *pinfo, proto_tree *tree _U_, void *data _U_)
{
  col_set_str(pinfo->cinfo, COL_PROTOCOL, "PROTO FOO");
  col_clear(pinfo->cinfo,COL_INFO);

  return tvb_captured_length(tvb);
}

// static void ws_protocol_register(mrb_state *mrb, mrb_value self)
static void ws_protocol_register(void)
{
  phandle = proto_register_protocol(
    "PROTOFOO Protocol",
    "PROTOFOO",
    "protofoo"
  );
}

static void ws_protocol_handoff(mrb_state *mrb, mrb_value self)
{
  static dissector_handle_t dhandle;
  dhandle = create_dissector_handle(dissect_proto1, phandle);

  mrb_value mrb_transport;
  mrb_transport = mrb_iv_get(mrb, self, mrb_intern_lit(mrb, "@transport"));
  mrb_transport = mrb_funcall(mrb, mrb_transport, "to_s", 0);

  dissector_add_uint(mrb_str_to_cstr(mrb, mrb_str_cat_lit(mrb, mrb_transport, ".port")),
                     PROTO1_PORT,
                     dhandle);
}

static mrb_value mrb_ws_protocol_dissect(mrb_state *mrb, mrb_value self)
{
  ws_protocol_register();
  ws_protocol_handoff(mrb, self);

  return self;
}

void mrb_ws_protocol_start(mrb_state *mrb, const char *pathname)
{
  FILE *ws_tree_src     = fopen("../plugins/epan/proto1/ws_tree.rb", "r");
  FILE *ws_protocol_src = fopen("../plugins/epan/proto1/ws_protocol.rb", "r");
  mrb_load_file(mrb, ws_tree_src);
  mrb_load_file(mrb, ws_protocol_src);

  mrb_value      mrb_ws_protocol_klass = mrb_obj_value(mrb_class_get(mrb, "WSProtocol"));
  struct RClass *ws_protocol_klass     = mrb_class_ptr(mrb_ws_protocol_klass);

  mrb_define_method(mrb, ws_protocol_klass, "dissect!", mrb_ws_protocol_dissect, MRB_ARGS_NONE());

  strcpy(config_src_path, pathname);
  FILE *config_src = fopen(config_src_path, "r");
  mrb_load_file(mrb, config_src);
}
