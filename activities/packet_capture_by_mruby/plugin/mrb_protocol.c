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
  const char *name;
  const char *filter_name;
  const char *tprotocol;
  int port;
} mrb_protocol_t;

static mrb_protocol_t mrb_protocol;

static char _mrb_protocol_name[100];
static char _mrb_protocol_filter_name[100];
static char _mrb_protocol_tprotocol[4];

static mrb_value mrb_protocol_init(mrb_state *mrb, mrb_value self)
{
  mrb_value name;
  mrb_sym   tprotocol;
  mrb_int   port;
  mrb_get_args(mrb, "Sni", &name, &tprotocol, &port);

  if ((tprotocol != mrb_intern_lit(mrb, "tcp")) && (tprotocol != mrb_intern_lit(mrb, "udp"))) {
    mrb_raisef(mrb, E_ARGUMENT_ERROR, "invalid tprotocol: %S", mrb_symbol_value(tprotocol));
  }

  mrb_iv_set(mrb, self, mrb_intern_lit(mrb, "@name"),        name);
  mrb_iv_set(mrb, self, mrb_intern_lit(mrb, "@filter_name"), mrb_funcall(mrb, name, "downcase", 0));
  mrb_iv_set(mrb, self, mrb_intern_lit(mrb, "@tprotocol"),   mrb_symbol_value(tprotocol));
  mrb_iv_set(mrb, self, mrb_intern_lit(mrb, "@port"),        mrb_int_value(mrb, port));

  return self;
}

static mrb_value mrb_protocol_get_name(mrb_state *mrb, mrb_value self)
{
  return mrb_iv_get(mrb, self, mrb_intern_lit(mrb, "@name"));
}

static mrb_value mrb_protocol_get_filter_name(mrb_state *mrb, mrb_value self)
{
  return mrb_iv_get(mrb, self, mrb_intern_lit(mrb, "@filter_name"));
}

static mrb_value mrb_protocol_get_tprotocol(mrb_state *mrb, mrb_value self)
{
  return mrb_iv_get(mrb, self, mrb_intern_lit(mrb, "@tprotocol"));
}

static mrb_value mrb_protocol_get_port(mrb_state *mrb, mrb_value self)
{
  return mrb_iv_get(mrb, self, mrb_intern_lit(mrb, "@port"));
}

static int _dissector(tvbuff_t *tvb, packet_info *pinfo, proto_tree *tree _U_, void *data _U_)
{
  col_set_str(pinfo->cinfo, COL_PROTOCOL, mrb_protocol.name);
  col_clear(pinfo->cinfo, COL_INFO);

  return tvb_captured_length(tvb);
}

static void _register_protocol(mrb_state *mrb, mrb_value protocol)
{
  mrb_value name = mrb_protocol_get_name(mrb, protocol);
  mrb_value filter_name = mrb_protocol_get_filter_name(mrb, protocol);

  phandle = proto_register_protocol(mrb_str_to_cstr(mrb, name),
                                    mrb_str_to_cstr(mrb, name),
                                    mrb_str_to_cstr(mrb, filter_name));
}

static void _register_handoff(mrb_state *mrb, mrb_value protocol)
{
  static dissector_handle_t dhandle;
  dhandle = create_dissector_handle(_dissector, phandle);
  mrb_value port = mrb_protocol_get_port(mrb, protocol);
  mrb_value tprotocol = mrb_funcall(mrb, mrb_protocol_get_tprotocol(mrb, protocol), "to_s", 0);

  dissector_add_uint(mrb_str_to_cstr(mrb, mrb_str_cat_lit(mrb, tprotocol, ".port")),
                     (unsigned int)mrb_fixnum(port),
                     dhandle);
}

static mrb_value mrb_protocol_enable(mrb_state *mrb, mrb_value protocol)
{
  mrb_value mrb_tmp_str;

  mrb_tmp_str = mrb_funcall(mrb, mrb_protocol_get_name(mrb, protocol), "to_s", 0);
  const char *tmp_cstr_name = mrb_string_cstr(mrb, mrb_tmp_str);

  if (sizeof(*tmp_cstr_name) > sizeof(_mrb_protocol_name)) {
    fprintf(stderr, "too long name");
    exit(1);
  } else {
    strcpy(_mrb_protocol_name, tmp_cstr_name);
  }

  mrb_tmp_str = mrb_funcall(mrb, mrb_protocol_get_filter_name(mrb, protocol), "to_s", 0);
  const char *tmp_cstr_filter_name = mrb_string_cstr(mrb, mrb_tmp_str);

  if (sizeof(*tmp_cstr_filter_name) > sizeof(_mrb_protocol_filter_name)) {
    fprintf(stderr, "too long filter name");
    exit(1);
  } else {
    strcpy(_mrb_protocol_filter_name, tmp_cstr_filter_name);
  }

  mrb_tmp_str = mrb_funcall(mrb, mrb_protocol_get_tprotocol(mrb, protocol), "to_s", 0);
  const char *tmp_cstr_tprotocol = mrb_string_cstr(mrb, mrb_tmp_str);

  if (sizeof(*tmp_cstr_tprotocol) > sizeof(_mrb_protocol_tprotocol)) {
    fprintf(stderr, "too long transport protocol");
    exit(1);
  } else {
    strcpy(_mrb_protocol_tprotocol, tmp_cstr_tprotocol);
  }

  mrb_protocol.name        = _mrb_protocol_name;
  mrb_protocol.filter_name = _mrb_protocol_filter_name;
  mrb_protocol.tprotocol   = _mrb_protocol_tprotocol;
  mrb_protocol.port        = (unsigned int)mrb_fixnum(mrb_protocol_get_port(mrb, protocol));

  _register_protocol(mrb, protocol);
  _register_handoff(mrb, protocol);

  return mrb_nil_value();
}

void mrb_protocol_gem_init(mrb_state *mrb)
{
  struct RClass *protocol_klass = mrb_define_class(mrb, "Protocol", mrb->object_class);
  mrb_define_method(mrb, protocol_klass, "initialize",  mrb_protocol_init,            MRB_ARGS_REQ(3));
  mrb_define_method(mrb, protocol_klass, "name",        mrb_protocol_get_name,        MRB_ARGS_NONE());
  mrb_define_method(mrb, protocol_klass, "filter_name", mrb_protocol_get_filter_name, MRB_ARGS_NONE());
  mrb_define_method(mrb, protocol_klass, "tprotocol",   mrb_protocol_get_tprotocol,   MRB_ARGS_NONE());
  mrb_define_method(mrb, protocol_klass, "port",        mrb_protocol_get_port,        MRB_ARGS_NONE());
  mrb_define_method(mrb, protocol_klass, "enable",      mrb_protocol_enable,          MRB_ARGS_NONE());
}