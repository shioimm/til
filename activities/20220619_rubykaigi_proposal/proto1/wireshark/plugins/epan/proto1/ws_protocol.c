#include "ws_protocol.h"

#define MRB_SYM(mrb, name) mrb_symbol_value(mrb_intern_lit(mrb, name))

typedef enum {
  REGISTERATION,
  DISSECTION,
} OperationMode;

char config_src_path[256];
static int phandle = -1;
static int operation_mode = REGISTERATION;

typedef struct {
  char name[100];
  char filter[100];
  char transport[4];
  unsigned int port;
} ws_protocol_t;

typedef struct {
  int symbol;
  int handle;
  int size;
} ws_field_t;

typedef struct {
  int size;
  ws_field_t fields[100];
} ws_header_fields_t;

typedef struct {
   int depth;
  gint ett;
} ws_ett_t;

static ws_protocol_t      ws_protocol;
static ws_header_fields_t ws_hfs;
static ws_ett_t           ws_etts[100];

mrb_value mrb_ws_protocol_start(mrb_state *mrb, const char *pathname);

static gint ws_protocol_detect_ws_ett(int depth)
{
  for (int i = 0; i < 100; i++) {
    if (ws_etts[i].depth == depth) return ws_etts[i].ett;
  }
}

static ws_field_t ws_protocol_detect_ws_field(int symbol)
{
  for (int i = 0; i < ws_hfs.size; i++) {
    if (ws_hfs.fields[i].symbol == symbol) return ws_hfs.fields[i];
  }
}

static void ws_protocol_add_items(mrb_state *mrb, mrb_value mrb_items, proto_item *ti, tvbuff_t *tvb)
{
  for (int i = 0; i < (int)RARRAY_LEN(mrb_items); i++) {
    mrb_value  mrb_item   = mrb_funcall(mrb, mrb_items, "fetch", 1, mrb_fixnum_value(i));
    mrb_value  mrb_size   = mrb_funcall(mrb, mrb_item,  "fetch", 1, MRB_SYM(mrb, "size"));
    mrb_value  mrb_offset = mrb_funcall(mrb, mrb_item,  "fetch", 1, MRB_SYM(mrb, "offset"));
    mrb_value  mrb_endian = mrb_funcall(mrb, mrb_item,  "fetch", 1, MRB_SYM(mrb, "endian"));
    mrb_value  mrb_sym    = mrb_funcall(mrb, mrb_item,  "fetch", 1, MRB_SYM(mrb, "field"));
    ws_field_t ws_field   = ws_protocol_detect_ws_field(mrb_obj_to_sym(mrb, mrb_sym));

    proto_tree_add_item(ti, ws_field.handle, tvb,
                        (int)mrb_fixnum(mrb_offset), (int)mrb_fixnum(mrb_size), (int)mrb_fixnum(mrb_endian));
  }
}

static void ws_protocol_add_subtree_items(mrb_state *mrb, mrb_value mrb_subtrees, proto_item *ti, tvbuff_t *tvb)
{
  for (int i = 0; i < (int)RARRAY_LEN(mrb_subtrees); i++) {
    mrb_value mrb_subtree = mrb_funcall(mrb, mrb_subtrees, "fetch", 1, mrb_fixnum_value(i));
    mrb_value mrb_name    = mrb_iv_get(mrb,  mrb_subtree, mrb_intern_lit(mrb, "@name"));
    mrb_value mrb_items   = mrb_iv_get(mrb,  mrb_subtree, mrb_intern_lit(mrb, "@items"));
    mrb_value mrb_depth   = mrb_iv_get(mrb,  mrb_subtree, mrb_intern_lit(mrb, "@depth"));
    gint ett = ws_protocol_detect_ws_ett((int)mrb_fixnum(mrb_depth));

    // WIP: 実装中 -----------------
    proto_tree *subtree = proto_tree_add_subtree(ti, tvb,
                                                 0, 1, ett, NULL, mrb_string_cstr(mrb, mrb_name));
    // -----------------------------

    ws_protocol_add_items(mrb, mrb_items, subtree, tvb);

    mrb_value mrb_s_subytrees = mrb_iv_get(mrb, mrb_subtree, mrb_intern_lit(mrb, "@subtrees"));
    ws_protocol_add_subtree_items(mrb, mrb_s_subytrees, subtree, tvb);
  }
}

static int ws_protocol_dissector(tvbuff_t *tvb, packet_info *pinfo, proto_tree *tree _U_, void *data _U_)
{
  if (operation_mode != DISSECTION) operation_mode = DISSECTION;

  mrb_state *mrb = mrb_open();
  mrb_value mrb_config = mrb_ws_protocol_start(mrb, "");
  mrb_value mrb_name   = mrb_iv_get(mrb, mrb_config, mrb_intern_lit(mrb, "@name"));

  col_set_str(pinfo->cinfo, COL_PROTOCOL, mrb_string_cstr(mrb, mrb_name));
  col_clear(pinfo->cinfo,COL_INFO);

  proto_item *ti = proto_tree_add_item(tree, phandle, tvb, 0, -1, ENC_NA);

  mrb_value mrb_dfs   = mrb_iv_get(mrb, mrb_config, mrb_intern_lit(mrb, "@dissect_fields"));
  mrb_value mrb_items = mrb_iv_get(mrb, mrb_dfs, mrb_intern_lit(mrb, "@items"));
  mrb_value mrb_depth = mrb_iv_get(mrb, mrb_dfs, mrb_intern_lit(mrb, "@depth"));
  gint ett = ws_protocol_detect_ws_ett((int)mrb_fixnum(mrb_depth));

  proto_tree *main_tree = proto_item_add_subtree(ti, ett);
  ws_protocol_add_items(mrb, mrb_items, main_tree, tvb);

  mrb_value mrb_subtrees = mrb_iv_get(mrb, mrb_dfs, mrb_intern_lit(mrb, "@subtrees"));
  ws_protocol_add_subtree_items(mrb, mrb_subtrees, main_tree, tvb);

  mrb_close(mrb);

  return tvb_captured_length(tvb);
}

static void ws_protocol_set_members(mrb_state *mrb, mrb_value self)
{
  mrb_value mrb_name      = mrb_iv_get(mrb, self, mrb_intern_lit(mrb, "@name"));
  mrb_value mrb_filter    = mrb_iv_get(mrb, self, mrb_intern_lit(mrb, "@filter"));
  mrb_value mrb_transport = mrb_iv_get(mrb, self, mrb_intern_lit(mrb, "@transport"));
  mrb_value mrb_port      = mrb_iv_get(mrb, self, mrb_intern_lit(mrb, "@port"));

  strcpy(ws_protocol.name, mrb_string_cstr(mrb, mrb_name));
  strcpy(ws_protocol.filter, mrb_string_cstr(mrb, mrb_filter));
  strcpy(ws_protocol.transport, mrb_string_cstr(mrb, mrb_funcall(mrb, mrb_transport, "to_s", 0)));
  ws_protocol.port = (unsigned int)mrb_fixnum(mrb_port);
}

static void ws_protocol_register(mrb_state *mrb, mrb_value self)
{
  ws_protocol_set_members(mrb, self);

  mrb_value mrb_hfs = mrb_iv_get(mrb, self, mrb_intern_lit(mrb, "@header_fields"));
  ws_hfs.size = (int)RARRAY_LEN(mrb_hfs);

  hf_register_info *hf = malloc(sizeof(hf_register_info) * ws_hfs.size);

  for (int i = 0; i < ws_hfs.size; i++) {
    mrb_value mrb_field = mrb_funcall(mrb, mrb_hfs, "at", 1, mrb_int_value(mrb, i));

    mrb_value mrb_hf_symbol  = mrb_funcall(mrb, mrb_field, "fetch", 1, MRB_SYM(mrb, "name"));
    mrb_value mrb_hf_name    = mrb_funcall(mrb, mrb_field, "fetch", 1, MRB_SYM(mrb, "label"));
    mrb_value mrb_hf_abbrev  = mrb_funcall(mrb, mrb_field, "fetch", 1, MRB_SYM(mrb, "filter"));
    mrb_value mrb_hf_type    = mrb_funcall(mrb, mrb_field, "fetch", 1, MRB_SYM(mrb, "cap_type"));
    mrb_value mrb_hf_display = mrb_funcall(mrb, mrb_field, "fetch", 1, MRB_SYM(mrb, "disp_type"));
    // WIP: mrb_value mrb_hf_descs   = mrb_funcall(mrb, mrb_field, "fetch", 1, MRB_SYM(mrb, "desc"));

    ws_hfs.fields[i].handle = -1;
    ws_hfs.fields[i].symbol = mrb_obj_to_sym(mrb, mrb_hf_symbol);

    char *hf_name   = malloc(sizeof(char) * mrb_fixnum(mrb_funcall(mrb, mrb_hf_name, "size", 0)));
    char *hf_abbrev = malloc(sizeof(char) * mrb_fixnum(mrb_funcall(mrb, mrb_hf_abbrev, "size", 0)));
    strcpy(hf_name,   mrb_str_to_cstr(mrb, mrb_hf_name));
    strcpy(hf_abbrev, mrb_str_to_cstr(mrb, mrb_hf_abbrev));

    hf[i].p_id = &ws_hfs.fields[i].handle;
    hf[i].hfinfo.name     = hf_name;
    hf[i].hfinfo.abbrev   = hf_abbrev;
    hf[i].hfinfo.type     = (int)mrb_fixnum(mrb_hf_type);
    hf[i].hfinfo.display  = (int)mrb_fixnum(mrb_hf_display);
    hf[i].hfinfo.strings  = NULL; // WIP
    hf[i].hfinfo.bitmask  = 0;    // WIP?;
    hf[i].hfinfo.blurb    = NULL;
    hf[i].hfinfo.id       = -1;
    hf[i].hfinfo.parent   = 0;
    hf[i].hfinfo.ref_type = HF_REF_TYPE_NONE;
    hf[i].hfinfo.same_name_prev_id = -1;
    hf[i].hfinfo.same_name_next    = NULL;
  }

  mrb_value mrb_dissector_depth = mrb_funcall(mrb, self, "dissector_depth", 0);
  gint **ett = malloc(sizeof(gint *) * (int)mrb_fixnum(mrb_dissector_depth));

  for (int i = 0; i < mrb_fixnum(mrb_dissector_depth); i++) {
    ws_etts[i].depth = i + 1;
    ws_etts[i].ett   = -1;
    ett[i] = &ws_etts[i].ett;
  }

  phandle = proto_register_protocol(
    ws_protocol.name,
    ws_protocol.name,
    ws_protocol.filter
  );

  proto_register_field_array(phandle, hf, ws_hfs.size);
  proto_register_subtree_array((gint *const *)ett, (int)mrb_fixnum(mrb_dissector_depth));
}

static void ws_protocol_handoff(mrb_state *mrb, mrb_value self)
{
  static dissector_handle_t dhandle;
  dhandle = create_dissector_handle(ws_protocol_dissector, phandle);

  mrb_value mrb_transport;
  mrb_transport = mrb_funcall(mrb, mrb_iv_get(mrb, self, mrb_intern_lit(mrb, "@transport")), "to_s", 0);

  dissector_add_uint(mrb_str_to_cstr(mrb, mrb_str_cat_lit(mrb, mrb_transport, ".port")),
                     ws_protocol.port,
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
  mrb_value mrb_dklass = mrb_obj_value(mrb_class_get(mrb, "WSDissector"));

  mrb_const_set(mrb, mrb_dklass,
                mrb_intern_lit(mrb, "ENC_NA"), mrb_fixnum_value(ENC_NA));
  mrb_const_set(mrb, mrb_dklass,
                mrb_intern_lit(mrb, "ENC_BIG_ENDIAN"), mrb_fixnum_value(ENC_BIG_ENDIAN));
  mrb_const_set(mrb, mrb_dklass,
                mrb_intern_lit(mrb, "ENC_LITTLE_ENDIAN"), mrb_fixnum_value(ENC_LITTLE_ENDIAN));

  return self;
}

static mrb_value mrb_ws_protocol_config(mrb_state *mrb, mrb_value self)
{
  mrb_value name, block;
  mrb_get_args(mrb, "S&", &name, &block);

  mrb_value proto = mrb_funcall(mrb, self, "new", 1, name);
  mrb_yield(mrb, block, proto);

  mrb_value mrb_config = mrb_nil_value();

  if (operation_mode == REGISTERATION) mrb_config = mrb_funcall(mrb, proto, "register!", 0);
  if (operation_mode == DISSECTION)    mrb_config = mrb_funcall(mrb, proto, "dissect!", 0);

  return mrb_config;
}

mrb_value mrb_ws_protocol_start(mrb_state *mrb, const char *pathname)
{
  FILE *ws_dissector_src = fopen("../plugins/epan/proto1/ws_dissector.rb", "r");
  FILE *ws_protocol_src  = fopen("../plugins/epan/proto1/ws_protocol.rb", "r");
  mrb_load_file(mrb, ws_dissector_src);
  mrb_load_file(mrb, ws_protocol_src);

  mrb_value      mrb_pklass = mrb_obj_value(mrb_class_get(mrb, "WSProtocol"));
  struct RClass *pklass     = mrb_class_ptr(mrb_pklass);

  mrb_define_method(mrb, pklass, "initialize", mrb_ws_protocol_init,     MRB_ARGS_REQ(1));
  mrb_define_method(mrb, pklass, "register!",  mrb_ws_protocol_register, MRB_ARGS_NONE());
  mrb_define_method(mrb, pklass, "dissect!",   mrb_ws_protocol_dissector,  MRB_ARGS_NONE());

  mrb_define_class_method(mrb, pklass,
                          "configure", mrb_ws_protocol_config, MRB_ARGS_REQ(1) | MRB_ARGS_BLOCK());

  mrb_const_set(mrb, mrb_pklass, mrb_intern_lit(mrb, "FT_UINT8"), mrb_fixnum_value(FT_UINT8));
  mrb_const_set(mrb, mrb_pklass, mrb_intern_lit(mrb, "BASE_DEC"), mrb_fixnum_value(BASE_DEC));

  if (operation_mode == REGISTERATION) strcpy(config_src_path, pathname);

  FILE *config_src = fopen(config_src_path, "r");
  return mrb_load_file(mrb, config_src);
}
