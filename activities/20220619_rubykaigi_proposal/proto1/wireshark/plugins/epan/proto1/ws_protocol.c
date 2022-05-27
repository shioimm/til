#include "ws_protocol.h"

typedef enum {
  REGISTERATION,
  DISSECTION,
} OperationMode;

char config_src_path[256];
static int phandle = -1;
static int operation_mode = REGISTERATION;

void mrb_ws_protocol_start(mrb_state *mrb, const char *pathname);

static int ws_protocol_dissector(tvbuff_t *tvb, packet_info *pinfo, proto_tree *tree _U_, void *data _U_)
{
  if (operation_mode != DISSECTION) operation_mode = DISSECTION;

  // mrb_state *mrb = mrb_open();
  // mrb_ws_protocol_start(mrb, "");
  // mrb_close(mrb);

  col_set_str(pinfo->cinfo, COL_PROTOCOL, "PROTO FOO");
  col_clear(pinfo->cinfo,COL_INFO);

  return tvb_captured_length(tvb);
}

static void ws_protocol_register(mrb_state *mrb, mrb_value self)
{
  mrb_p(mrb, self);

  phandle = proto_register_protocol(
    "PROTOFOO Protocol",
    "PROTOFOO",
    "protofoo"
  );
}

static void ws_protocol_handoff(mrb_state *mrb, mrb_value self)
{
  static dissector_handle_t dhandle;
  dhandle = create_dissector_handle(ws_protocol_dissector, phandle);

  mrb_value mrb_transport, mrb_port;
  mrb_transport = mrb_iv_get(mrb, self, mrb_intern_lit(mrb, "@transport"));
  mrb_transport = mrb_funcall(mrb, mrb_transport, "to_s", 0);
  mrb_port      = mrb_iv_get(mrb, self, mrb_intern_lit(mrb, "@port"));

  dissector_add_uint(mrb_str_to_cstr(mrb, mrb_str_cat_lit(mrb, mrb_transport, ".port")),
                     (unsigned int)mrb_fixnum(mrb_port),
                     dhandle);
}

static mrb_value mrb_ws_protocol_init(mrb_state *mrb, mrb_value self)
{
  mrb_value name;
  mrb_get_args(mrb, "S", &name);
  mrb_iv_set(mrb, self, mrb_intern_lit(mrb, "@name"), name);
  return self;
}

static mrb_value mrb_ws_protocol_register(mrb_state *mrb, mrb_value self)
{
  ws_protocol_register(mrb, self);
  ws_protocol_handoff(mrb, self);
  return self;
}

static mrb_value mrb_ws_protocol_dissector(mrb_state *mrb, mrb_value self)
{
  mrb_p(mrb, self);
  return self;
}

static mrb_value mrb_ws_protocol_config(mrb_state *mrb, mrb_value self)
{
  mrb_value name, block;
  mrb_get_args(mrb, "S&", &name, &block);

  mrb_value proto = mrb_funcall(mrb, self, "new", 1, name);
  mrb_yield(mrb, block, proto);

  if (operation_mode == REGISTERATION) mrb_funcall(mrb, proto, "register!", 0);
  if (operation_mode == DISSECTION)    mrb_funcall(mrb, proto, "dissect!", 0);

  return self;
}

void mrb_ws_protocol_start(mrb_state *mrb, const char *pathname)
{
  FILE *ws_tree_src     = fopen("../plugins/epan/proto1/ws_tree.rb", "r");
  FILE *ws_protocol_src = fopen("../plugins/epan/proto1/ws_protocol.rb", "r");
  mrb_load_file(mrb, ws_tree_src);
  mrb_load_file(mrb, ws_protocol_src);

  mrb_value      mrb_klass = mrb_obj_value(mrb_class_get(mrb, "WSProtocol"));
  struct RClass *klass     = mrb_class_ptr(mrb_klass);

  mrb_define_method(mrb, klass, "initialize", mrb_ws_protocol_init,     MRB_ARGS_REQ(1));
  mrb_define_method(mrb, klass, "register!",  mrb_ws_protocol_register, MRB_ARGS_NONE());
  mrb_define_method(mrb, klass, "dissect!",   mrb_ws_protocol_dissector,  MRB_ARGS_NONE());

  mrb_define_class_method(mrb, klass,
                          "configure", mrb_ws_protocol_config, MRB_ARGS_REQ(1) | MRB_ARGS_BLOCK());

  if (operation_mode == REGISTERATION) strcpy(config_src_path, pathname);

  FILE *config_src = fopen(config_src_path, "r");
  mrb_load_file(mrb, config_src);
}
