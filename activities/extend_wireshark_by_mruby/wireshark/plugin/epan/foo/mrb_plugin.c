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

static  int phandle   = -1;
static gint ett_state = -1;

typedef struct {
  char name[100];
  char filter_name[100];
  char protocol[4];
  unsigned int port;
  unsigned int subtree;
} plugin_t;

typedef enum {
  NORMAL,
  WITHBIT,
  BITMASK,
} PacketType;

typedef struct {
  int handle;
  int size;
  int symbol;
  PacketType type;
} field_t;

typedef struct {
  int field_size;
  int field_handles[100];
  field_t fields[100];
} subtree_t;

static plugin_t  plugin;
static subtree_t subtree;

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

  strcpy(plugin.name, mrb_string_cstr(mrb, name));
  strcpy(plugin.filter_name, mrb_string_cstr(mrb, mrb_funcall(mrb, name, "downcase", 0)));
  strcpy(plugin.protocol, mrb_string_cstr(mrb, mrb_funcall(mrb, mrb_symbol_value(protocol), "to_s", 0)));
  plugin.port = (unsigned int)port;

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
  mrb_value mrb_subtree = mrb_load_string(mrb, "Subtree.new");
  mrb_iv_set(mrb, self, mrb_intern_lit(mrb, "@subtree"), mrb_subtree);
  mrb_iv_set(mrb, mrb_subtree, mrb_intern_lit(mrb, "@plugin"), self);

  plugin.subtree = 1;
  return mrb_subtree;
}

static int _dissector(tvbuff_t *tvb, packet_info *pinfo, proto_tree *tree _U_, void *data _U_)
{
  col_set_str(pinfo->cinfo, COL_PROTOCOL, plugin.name);
  col_clear(pinfo->cinfo, COL_INFO);

  if (plugin.subtree == 1) {
    proto_item *ti = proto_tree_add_item(tree, phandle, tvb, 0, -1, ENC_NA);
    proto_tree *foo_tree = proto_item_add_subtree(ti, ett_state);

    gint offset = 0;
    field_t field;

    // WIP: Adding Flags to the protocol.
    static int* const bits[] = {
      &subtree.fields[2].handle,
      &subtree.fields[3].handle,
      &subtree.fields[4].handle,
      NULL
    };

    for (int i = 0; i < subtree.field_size; i++) {
      field = subtree.fields[i];

      if (field.type == NORMAL) {
        proto_tree_add_item(foo_tree, field.handle, tvb, offset, field.size, ENC_BIG_ENDIAN);
        offset += field.size;
      } else if (field.type == WITHBIT) {
        proto_tree_add_bitmask(foo_tree, tvb, offset, field.handle, ett_state, bits, ENC_BIG_ENDIAN);
        offset += 1;
      } else if (field.type == BITMASK) {
        continue;
      }
    }
  }

  return tvb_captured_length(tvb);
}

static int hf_packet_type(char *name)
{
  if (strcmp(name, "NORMAL") == 0) {
    return NORMAL;
  } else if (strcmp(name, "WITHBIT") == 0) {
    return WITHBIT;
  } else if (strcmp(name, "BITMASK") == 0) {
    return BITMASK;
  }

  return 0;
}

static int hf_field_type(char *name)
{
  if (strcmp(name, "FT_UINT8") == 0) {
    return FT_UINT8;
  } else if (strcmp(name, "FT_UINT16") == 0) {
    return FT_UINT16;
  } else if (strcmp(name, "FT_IPv4") == 0) {
    return FT_IPv4;
  } else if (strcmp(name, "FT_BOOLEAN") == 0) {
    return FT_BOOLEAN;
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
  } else {
    atoi(name);
  }

  return 0;
}

static void _mrb_register_plugin(mrb_state *mrb, mrb_value self)
{
  phandle = proto_register_protocol(plugin.name, plugin.name, plugin.filter_name);

  if (plugin.subtree == 1) {
    mrb_value mrb_subtree = mrb_iv_get(mrb, self, mrb_intern_lit(mrb, "@subtree"));
    mrb_value fields  = mrb_funcall(mrb, mrb_subtree, "fields", 0);
    subtree.field_size = (int)RARRAY_LEN(mrb_funcall(mrb, mrb_subtree, "fields", 0));

    hf_register_info *hf = malloc(sizeof(hf_register_info) * (subtree.field_size));

    for (int i = 0; i < subtree.field_size; i++) {
      mrb_value field = mrb_funcall(mrb, fields, "at", 1, mrb_int_value(mrb, i));

      mrb_value mrb_hf_type       = mrb_funcall(mrb, field, "fetch", 1, MRB_SYM(mrb, "type"));
      mrb_value mrb_hf_symbol     = mrb_funcall(mrb, field, "fetch", 1, MRB_SYM(mrb, "symbol"));
      mrb_value mrb_hf_name       = mrb_funcall(mrb, field, "fetch", 1, MRB_SYM(mrb, "label"));
      mrb_value mrb_hf_abbrev     = mrb_funcall(mrb, field, "fetch", 1, MRB_SYM(mrb, "filter"));
      mrb_value mrb_hf_field_type = mrb_funcall(mrb, field, "fetch", 1, MRB_SYM(mrb, "field_type"));
      mrb_value mrb_hf_int_type   = mrb_funcall(mrb, field, "fetch", 1, MRB_SYM(mrb, "int_type"));
      mrb_value mrb_hf_size       = mrb_funcall(mrb, field, "fetch", 1, MRB_SYM(mrb, "size"));
      mrb_value mrb_hf_descs      = mrb_funcall(mrb, field, "fetch", 1, MRB_SYM(mrb, "desc"));
      mrb_value mrb_hf_bitmack    = mrb_funcall(mrb, field, "fetch", 1, MRB_SYM(mrb, "bitmask"));

      char *hf_name   = malloc(sizeof(char) * mrb_fixnum(mrb_funcall(mrb, mrb_hf_name, "size", 0)));
      char *hf_abbrev = malloc(sizeof(char) * mrb_fixnum(mrb_funcall(mrb, mrb_hf_abbrev, "size", 0)));

      value_string *hf_desc;

      if (!mrb_nil_p(mrb_hf_descs)) {
        mrb_value mrb_hf_desc_size = mrb_funcall(mrb, mrb_hf_descs, "size", 0);
        hf_desc = malloc(sizeof(value_string) * mrb_fixnum(mrb_hf_desc_size));

        for (int hf_desc_i = 0; hf_desc_i < mrb_fixnum(mrb_hf_desc_size); hf_desc_i++) {
          mrb_value mrb_hf_desc = mrb_funcall(mrb, mrb_hf_descs, "fetch", 1, mrb_fixnum_value(hf_desc_i));
          mrb_value mrb_hf_desc_k = mrb_funcall(mrb, mrb_hf_desc, "fetch", 1, mrb_fixnum_value(0));
          mrb_value mrb_hf_desc_v = mrb_funcall(mrb, mrb_hf_desc, "fetch", 1, mrb_fixnum_value(1));
          mrb_hf_desc_k = mrb_funcall(mrb, mrb_hf_desc_k, "to_s", 0);

          guint32 hf_desc_val = (guint32)mrb_fixnum(mrb_hf_desc_v);
          gchar *hf_desc_str = malloc(sizeof(gchar) * mrb_fixnum(mrb_funcall(mrb, mrb_hf_desc_k, "size", 0)));
          strcpy(hf_desc_str, mrb_str_to_cstr(mrb, mrb_hf_desc_k));

          hf_desc[hf_desc_i].value  = hf_desc_val;
          hf_desc[hf_desc_i].strptr = hf_desc_str;
        }
      }

      strcpy(hf_name, mrb_str_to_cstr(mrb, mrb_hf_name));
      strcpy(hf_abbrev, mrb_str_to_cstr(mrb, mrb_hf_abbrev));

      subtree.fields[i].handle = -1;
      subtree.fields[i].size   = (int)mrb_fixnum(mrb_hf_size);
      subtree.fields[i].symbol = mrb_obj_to_sym(mrb, mrb_hf_symbol);
      subtree.fields[i].type   = hf_packet_type(mrb_str_to_cstr(mrb, mrb_hf_type));

      hf[i].p_id = &subtree.fields[i].handle;
      hf[i].hfinfo.name     = hf_name;
      hf[i].hfinfo.abbrev   = hf_abbrev;
      hf[i].hfinfo.type     = hf_field_type(mrb_str_to_cstr(mrb, mrb_hf_field_type));
      hf[i].hfinfo.display  = hf_display(mrb_str_to_cstr(mrb, mrb_hf_int_type));
      hf[i].hfinfo.strings  = !mrb_nil_p(mrb_hf_descs) ? VALS(hf_desc) : NULL;
      hf[i].hfinfo.bitmask  = mrb_fixnum(mrb_hf_bitmack);
      hf[i].hfinfo.blurb    = NULL;
      hf[i].hfinfo.id       = -1;
      hf[i].hfinfo.parent   = 0;
      hf[i].hfinfo.ref_type = HF_REF_TYPE_NONE;
      hf[i].hfinfo.same_name_prev_id = -1;
      hf[i].hfinfo.same_name_next    = NULL;
    }

    static gint *ett[] = { &ett_state };

    proto_register_field_array(phandle, hf, subtree.field_size);

    proto_register_subtree_array(ett, array_length(ett));
  }
}

static void _mrb_register_handoff(mrb_state *mrb, mrb_value self)
{
  static dissector_handle_t dhandle;
  dhandle = create_dissector_handle(_dissector, phandle);
  mrb_value protocol = mrb_funcall(mrb, mrb_plugin_get_protocol(mrb, self), "to_s", 0);

  dissector_add_uint(mrb_str_to_cstr(mrb, mrb_str_cat_lit(mrb, protocol, ".port")),
                     plugin.port,
                     dhandle);
}

static mrb_value mrb_plugin_dissect(mrb_state *mrb, mrb_value self)
{
  mrb_value blk;
  mrb_get_args(mrb, "|&", &blk);

  if (!mrb_nil_p(blk)) {
    mrb_value mrb_subtree = mrb_funcall(mrb, self, "add_subtree", 0);
    mrb_yield(mrb, blk, mrb_subtree);
  }

  _mrb_register_plugin(mrb, self);
  _mrb_register_handoff(mrb, self);

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
