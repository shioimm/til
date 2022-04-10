#include "config.h"
#include <epan/packet.h>

#include <mruby.h>
#include <mruby/compile.h>
#include <mruby/class.h>
#include <mruby/numeric.h>
#include <mruby/variable.h>
#include <mruby/value.h>
#include <mruby/string.h>

static int phandle = -1;

typedef struct {
  char name[100];
  char filter_name[100];
  char protocol[4];
  int port;
} mrb_plugin_t;

static mrb_plugin_t mrb_plugin;

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
  mrb_iv_set(mrb, self, mrb_intern_lit(mrb, "@protocol"),   mrb_symbol_value(protocol));
  mrb_iv_set(mrb, self, mrb_intern_lit(mrb, "@port"),        mrb_int_value(mrb, port));

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

static int _dissector(tvbuff_t *tvb, packet_info *pinfo, proto_tree *tree _U_, void *data _U_)
{
  col_set_str(pinfo->cinfo, COL_PROTOCOL, mrb_plugin.name);
  col_clear(pinfo->cinfo, COL_INFO);

  return tvb_captured_length(tvb);
}

static void _register_plugin(mrb_state *mrb, mrb_value plugin)
{
  mrb_value name = mrb_plugin_get_name(mrb, plugin);
  mrb_value filter_name = mrb_plugin_get_filter_name(mrb, plugin);

  phandle = proto_register_protocol(mrb_str_to_cstr(mrb, name),
                                    mrb_str_to_cstr(mrb, name),
                                    mrb_str_to_cstr(mrb, filter_name));
}

static void _register_handoff(mrb_state *mrb, mrb_value plugin)
{
  static dissector_handle_t dhandle;
  dhandle = create_dissector_handle(_dissector, phandle);
  mrb_value port = mrb_plugin_get_port(mrb, plugin);
  mrb_value protocol = mrb_funcall(mrb, mrb_plugin_get_protocol(mrb, plugin), "to_s", 0);

  dissector_add_uint(mrb_str_to_cstr(mrb, mrb_str_cat_lit(mrb, protocol, ".port")),
                     (unsigned int)mrb_fixnum(port),
                     dhandle);
}

static mrb_value mrb_plugin_enable(mrb_state *mrb, mrb_value plugin)
{
  mrb_value mrb_tmp_str;

  mrb_tmp_str = mrb_funcall(mrb, mrb_plugin_get_name(mrb, plugin), "to_s", 0);
  const char *tmp_cstr_name = mrb_string_cstr(mrb, mrb_tmp_str);
  strcpy(mrb_plugin.name, tmp_cstr_name);

  mrb_tmp_str = mrb_funcall(mrb, mrb_plugin_get_filter_name(mrb, plugin), "to_s", 0);
  const char *tmp_cstr_filter_name = mrb_string_cstr(mrb, mrb_tmp_str);
  strcpy(mrb_plugin.filter_name, tmp_cstr_filter_name);

  mrb_tmp_str = mrb_funcall(mrb, mrb_plugin_get_protocol(mrb, plugin), "to_s", 0);
  const char *tmp_cstr_protocol = mrb_string_cstr(mrb, mrb_tmp_str);
  strcpy(mrb_plugin.protocol, tmp_cstr_protocol);

  mrb_plugin.port = (unsigned int)mrb_fixnum(mrb_plugin_get_port(mrb, plugin));

  mrb_value blk;
  mrb_get_args(mrb, "|&", &blk);

  if (!mrb_nil_p(blk)) {
    mrb_yield(mrb, blk, plugin);
  }

  _register_plugin(mrb, plugin);
  _register_handoff(mrb, plugin);

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
  mrb_define_method(mrb, plugin_klass, "enable",      mrb_plugin_enable,          MRB_ARGS_NONE() | MRB_ARGS_BLOCK());
}
