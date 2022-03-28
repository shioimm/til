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
  mrb_iv_set(mrb, self, mrb_intern_lit(mrb, "@tprotocol"),    mrb_symbol_value(tprotocol));
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

static int mrb_dissect(tvbuff_t *tvb, packet_info *pinfo, proto_tree *tree _U_, void *data _U_)
{
  col_set_str(pinfo->cinfo, COL_PROTOCOL, "FOO");
  col_clear(pinfo->cinfo, COL_INFO);
  return tvb_captured_length(tvb);
}

static void mrb_register_protocol(mrb_value protocol)
{
  phandle = proto_register_protocol(
    "FOO Protocol",
    "FOO",
    "foo"
  );
}

static void mrb_register_handoff(mrb_value protocol)
{
  static dissector_handle_t dhandle;

  dhandle = create_dissector_handle(mrb_dissect, phandle);
  dissector_add_uint("tcp.port", 30000, dhandle);
}

void mrb_protocol_gem_init(mrb_state *mrb)
{
  struct RClass *protocol_klass = mrb_define_class(mrb, "Protocol", mrb->object_class);
  mrb_define_method(mrb, protocol_klass, "initialize",   mrb_protocol_init,            MRB_ARGS_REQ(3));
  mrb_define_method(mrb, protocol_klass, "name",         mrb_protocol_get_name,        MRB_ARGS_NONE());
  mrb_define_method(mrb, protocol_klass, "filter_name",  mrb_protocol_get_filter_name, MRB_ARGS_NONE());
  mrb_define_method(mrb, protocol_klass, "tprotocol",    mrb_protocol_get_tprotocol,    MRB_ARGS_NONE());
  mrb_define_method(mrb, protocol_klass, "port",         mrb_protocol_get_port,        MRB_ARGS_NONE());
}
