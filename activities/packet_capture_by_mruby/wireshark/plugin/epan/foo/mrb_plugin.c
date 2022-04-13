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

#include "mrb_subtree.c"

static int phandle = -1;

typedef struct {
  char name[100];
  char filter_name[100];
  char protocol[4];
  unsigned int port;
  unsigned int subtree;
} mrb_plugin_t;

typedef struct {
  int field_handles[100];
} mrb_subtree_t;

static mrb_plugin_t  mrb_plugin;
static mrb_subtree_t mrb_subtree;

static int hf_foo_pdu_type   = -1;
static int hf_foo_flags      = -1;
static int hf_foo_sequenceno = -1;
static int hf_foo_initialip  = -1;

static gint ett_foo  = -1;

static mrb_value mrb_plugin_init(mrb_state *mrb, mrb_value self)
{
  mrb_value name;
  mrb_sym   protocol;
  mrb_int   port;
  mrb_get_args(mrb, "Sni", &name, &protocol, &port);

  if (protocol != mrb_intern_lit(mrb, "tcp")) {
    mrb_raisef(mrb, E_ARGUMENT_ERROR, "invalid protocol: %S", mrb_symbol_value(protocol));
  }
  if (mrb_fixnum(mrb_funcall(mrb, name, "size", 0)) > 100) {
    mrb_raisef(mrb, E_ARGUMENT_ERROR, "too long name: %S", mrb_symbol_value(mrb_obj_to_sym(mrb, name)));
  }

  mrb_iv_set(mrb, self, mrb_intern_lit(mrb, "@name"),        name);
  mrb_iv_set(mrb, self, mrb_intern_lit(mrb, "@filter_name"), mrb_funcall(mrb, name, "downcase", 0));
  mrb_iv_set(mrb, self, mrb_intern_lit(mrb, "@protocol"),    mrb_symbol_value(protocol));
  mrb_iv_set(mrb, self, mrb_intern_lit(mrb, "@port"),        mrb_int_value(mrb, port));

  strcpy(mrb_plugin.name, mrb_string_cstr(mrb, name));
  strcpy(mrb_plugin.filter_name, mrb_string_cstr(mrb, mrb_funcall(mrb, name, "downcase", 0)));
  strcpy(mrb_plugin.protocol, mrb_string_cstr(mrb, mrb_funcall(mrb, mrb_symbol_value(protocol), "to_s", 0)));
  mrb_plugin.port = (unsigned int)port;

  return self;
}

static mrb_value mrb_plugin_get_name(mrb_state *mrb, mrb_value self)
{
  return mrb_iv_get(mrb, self, mrb_intern_lit(mrb, "@name"));
}

static mrb_value mrb_plugin_get_filter_name(mrb_state *mrb, mrb_value self)
{
  return mrb_iv_get(mrb, self, mrb_intern_lit(mrb, "@filter_name"));
}

static mrb_value mrb_plugin_get_protocol(mrb_state *mrb, mrb_value self)
{
  return mrb_iv_get(mrb, self, mrb_intern_lit(mrb, "@protocol"));
}

static mrb_value mrb_plugin_get_port(mrb_state *mrb, mrb_value self)
{
  return mrb_iv_get(mrb, self, mrb_intern_lit(mrb, "@port"));
}

static mrb_value mrb_plugin_add_subtree(mrb_state *mrb, mrb_value self)
{
  mrb_value subtree = mrb_load_string(mrb, "SubTree.new");
  mrb_iv_set(mrb, self, mrb_intern_lit(mrb, "@subtree"), subtree);
  mrb_iv_set(mrb, subtree, mrb_intern_lit(mrb, "@plugin"), self);

  mrb_plugin.subtree = 1;
  return subtree;
}

static int _dissector(tvbuff_t *tvb, packet_info *pinfo, proto_tree *tree _U_, void *data _U_)
{
  col_set_str(pinfo->cinfo, COL_PROTOCOL, mrb_plugin.name);
  col_clear(pinfo->cinfo, COL_INFO);

  if (mrb_plugin.subtree == 1) {
    gint offset = 0;
    proto_item *ti = proto_tree_add_item(tree, phandle, tvb, 0, -1, ENC_NA);
    proto_tree *foo_tree = proto_item_add_subtree(ti, ett_foo);

    // proto_tree_add_item(foo_tree, hf_foo_pdu_type, tvb, 0, 1, ENC_BIG_ENDIAN);
    // offset += 1;
    // proto_tree_add_item(foo_tree, hf_foo_flags, tvb, offset, 1, ENC_BIG_ENDIAN);
    // offset += 1;
    // proto_tree_add_item(foo_tree, hf_foo_sequenceno, tvb, offset, 2, ENC_BIG_ENDIAN);
    // offset += 2;
    // proto_tree_add_item(foo_tree, hf_foo_initialip, tvb, offset, 4, ENC_BIG_ENDIAN);
    // offset += 4;

    proto_tree_add_item(foo_tree, mrb_subtree.field_handles[0], tvb, 0, 1, ENC_BIG_ENDIAN);
    offset += 1;
    proto_tree_add_item(foo_tree, mrb_subtree.field_handles[1], tvb, offset, 1, ENC_BIG_ENDIAN);
    offset += 1;
    proto_tree_add_item(foo_tree, mrb_subtree.field_handles[2], tvb, offset, 2, ENC_BIG_ENDIAN);
    offset += 2;
    proto_tree_add_item(foo_tree, mrb_subtree.field_handles[3], tvb, offset, 4, ENC_BIG_ENDIAN);
    offset += 4;
  }

  return tvb_captured_length(tvb);
}

#define HF_FIELD_TYPE(name)                   \
  if (strcmp(#name, "FT_UINT8") == 0) {       \
    return FT_UINT8;                          \
  else if (strcmp(#name, "FT_UINT16") == 0) { \
    return FT_UINT16;                         \
  else if (strcmp(#name, "FT_IPv4") == 0) {   \
    return FT_IPv4;                           \
  else                                        \
    return 0;                                 \
  }

static int hf_field_type(char *name)
{
  if (strcmp(name, "FT_UINT8") == 0) {
    return FT_UINT8;
  } else if (strcmp(name, "FT_UINT16") == 0) {
    return FT_UINT16;
  } else if (strcmp(name, "FT_IPv4") == 0) {
    return FT_IPv4;
  }

  return 0;
}

static int hf_display(char *name)
{
  if (strcmp(name, "BASE_DEC") == 0) {
    return BASE_DEC;
  } else if (strcmp(name, "BASE_HEX") == 0) {
    return BASE_HEX;
  } else if (strcmp(name, "BASE_NONE") == 0) {
    return BASE_NONE;
  }

  return 0;
}

static void _register_plugin(mrb_state *mrb, mrb_value self)
{
  phandle = proto_register_protocol(mrb_plugin.name, mrb_plugin.name, mrb_plugin.filter_name);

  if (mrb_plugin.subtree == 1) {
    mrb_value subtree = mrb_iv_get(mrb, self, mrb_intern_lit(mrb, "@subtree"));
    mrb_value fields  = mrb_funcall(mrb, subtree, "fields", 0);
    int field_size    = (int)RARRAY_LEN(mrb_funcall(mrb, subtree, "fields", 0));

    static hf_register_info hf[4];

    for (int i = 0; i < field_size; i++) {
      mrb_subtree.field_handles[i] = -1;
      mrb_value field = mrb_funcall(mrb, fields, "at", 1, mrb_int_value(mrb, i));

      mrb_value mrb_hf_name       = mrb_funcall(mrb, field, "fetch", 1, MRB_SYM(mrb, "label"));
      mrb_value mrb_hf_abbrev     = mrb_funcall(mrb, field, "fetch", 1, MRB_SYM(mrb, "filter"));
      mrb_value mrb_hf_field_type = mrb_funcall(mrb, field, "fetch", 1, MRB_SYM(mrb, "field_type"));
      mrb_value mrb_hf_int_type   = mrb_funcall(mrb, field, "fetch", 1, MRB_SYM(mrb, "int_type"));

      char *hf_name   = malloc(sizeof(char) * mrb_fixnum(mrb_funcall(mrb, mrb_hf_name, "size", 0)));
      char *hf_abbrev = malloc(sizeof(char) * mrb_fixnum(mrb_funcall(mrb, mrb_hf_abbrev, "size", 0)));

      strcpy(hf_name, mrb_str_to_cstr(mrb, mrb_hf_name));
      strcpy(hf_abbrev, mrb_str_to_cstr(mrb, mrb_hf_abbrev));

      hf[i].p_id = &mrb_subtree.field_handles[i];
      hf[i].hfinfo.name     = hf_name;
      hf[i].hfinfo.abbrev   = hf_abbrev;
      hf[i].hfinfo.type     = hf_field_type(mrb_str_to_cstr(mrb, mrb_hf_field_type));
      hf[i].hfinfo.display  = hf_display(mrb_str_to_cstr(mrb, mrb_hf_int_type));
      hf[i].hfinfo.strings  = NULL;
      hf[i].hfinfo.bitmask  = 0x0;
      hf[i].hfinfo.blurb    = NULL;
      hf[i].hfinfo.id       = -1;
      hf[i].hfinfo.parent   = 0;
      hf[i].hfinfo.ref_type = HF_REF_TYPE_NONE;
      hf[i].hfinfo.same_name_prev_id = -1;
      hf[i].hfinfo.same_name_next    = NULL;
    }

    for (int i = 0; i < field_size; i++) {
      printf("%d\n", *(hf[i].p_id));
      printf("%s\n", hf[i].hfinfo.name);
      printf("%s\n", hf[i].hfinfo.abbrev);
      printf("%d\n", hf[i].hfinfo.type);
      printf("%d\n", hf[i].hfinfo.display);
      printf("%s\n", (char *)hf[i].hfinfo.strings);
      printf("%d\n", (int)hf[i].hfinfo.bitmask);
      printf("%d\n", hf[i].hfinfo.id);
      printf("%d\n", hf[i].hfinfo.parent);
      printf("%d\n", hf[i].hfinfo.ref_type);
      printf("%d\n", hf[i].hfinfo.same_name_prev_id);
      printf("%p\n", hf[i].hfinfo.same_name_next);
    }

    // static hf_register_info hf[] = {
    //   { &hf_foo_pdu_type,
    //     { "FOO PDU Type",            "foo.type",      FT_UINT8,  BASE_DEC,  NULL, 0x0, NULL, HFILL } },
    //   { &hf_foo_flags,
    //     { "FOO PDU Flags",           "foo.flags",     FT_UINT8,  BASE_HEX,  NULL, 0x0, NULL, HFILL } },
    //   { &hf_foo_sequenceno,
    //     { "FOO PDU Sequence Number", "foo.seqn",      FT_UINT16, BASE_DEC,  NULL, 0x0, NULL, HFILL } },
    //   { &hf_foo_initialip,
    //     { "FOO PDU Initial IP",      "foo.initialip", FT_IPv4,   BASE_NONE, NULL, 0x0, NULL, HFILL } },
    // };

    static gint *ett[] = { &ett_foo };

    proto_register_field_array(phandle, hf, (int)array_length(hf));
    proto_register_subtree_array(ett, array_length(ett));
  }
}

static void _register_handoff(mrb_state *mrb, mrb_value self)
{
  static dissector_handle_t dhandle;
  dhandle = create_dissector_handle(_dissector, phandle);
  mrb_value protocol = mrb_funcall(mrb, mrb_plugin_get_protocol(mrb, self), "to_s", 0);

  dissector_add_uint(mrb_str_to_cstr(mrb, mrb_str_cat_lit(mrb, protocol, ".port")),
                     mrb_plugin.port,
                     dhandle);
}

static mrb_value mrb_plugin_dissect(mrb_state *mrb, mrb_value self)
{
  mrb_value blk;
  mrb_get_args(mrb, "|&", &blk);

  if (!mrb_nil_p(blk)) {
    mrb_value subtree = mrb_funcall(mrb, self, "add_subtree", 0);
    mrb_yield(mrb, blk, subtree);
  }

  _register_plugin(mrb, self);
  _register_handoff(mrb, self);

  return mrb_true_value();
}

void mrb_plugin_gem_init(mrb_state *mrb)
{
  struct RClass *plugin_klass = mrb_define_class(mrb, "Plugin", mrb->object_class);
  mrb_define_method(mrb, plugin_klass, "initialize",  mrb_plugin_init,            MRB_ARGS_REQ(3));
  mrb_define_method(mrb, plugin_klass, "name",        mrb_plugin_get_name,        MRB_ARGS_NONE());
  mrb_define_method(mrb, plugin_klass, "filter_name", mrb_plugin_get_filter_name, MRB_ARGS_NONE());
  mrb_define_method(mrb, plugin_klass, "protocol",    mrb_plugin_get_protocol,    MRB_ARGS_NONE());
  mrb_define_method(mrb, plugin_klass, "port",        mrb_plugin_get_port,        MRB_ARGS_NONE());
  mrb_define_method(mrb, plugin_klass, "add_subtree", mrb_plugin_add_subtree,     MRB_ARGS_NONE());
  mrb_define_method(mrb, plugin_klass, "dissect",     mrb_plugin_dissect,         MRB_ARGS_NONE() | MRB_ARGS_BLOCK());
  mrb_subtree_gem_init(mrb);
}
