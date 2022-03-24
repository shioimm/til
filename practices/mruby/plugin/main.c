#include <mruby.h>
#include <mruby/compile.h>
#include <mruby/class.h>
#include <mruby/numeric.h>
#include <mruby/variable.h>
#include <mruby/value.h>

#include <string.h>

static mrb_value mrb_plugin_init(mrb_state *mrb, mrb_value self)
{
  mrb_value name;
  mrb_sym   protocol;
  mrb_int   port;
  mrb_get_args(mrb, "Sni", &name, &protocol, &port);

  if ((protocol != mrb_intern_lit(mrb, "tcp")) && (protocol != mrb_intern_lit(mrb, "udp"))) {
    mrb_raisef(mrb, E_ARGUMENT_ERROR, "invalid protocol: %S", mrb_symbol_value(protocol));
  }

  mrb_iv_set(mrb, self, mrb_intern_lit(mrb, "@name"),        name);
  mrb_iv_set(mrb, self, mrb_intern_lit(mrb, "@filter_name"), mrb_funcall(mrb, name, "downcase", 0));
  mrb_iv_set(mrb, self, mrb_intern_lit(mrb, "@protocol"),    mrb_symbol_value(protocol));
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

int main()
{
  mrb_state *mrb = mrb_open();

  struct RClass *plugin_klass = mrb_define_class(mrb, "Plugin", mrb->object_class);
  mrb_define_method(mrb, plugin_klass, "initialize",   mrb_plugin_init,            MRB_ARGS_REQ(3));
  mrb_define_method(mrb, plugin_klass, "name",         mrb_plugin_get_name,        MRB_ARGS_NONE());
  mrb_define_method(mrb, plugin_klass, "filter_name",  mrb_plugin_get_filter_name, MRB_ARGS_NONE());
  mrb_define_method(mrb, plugin_klass, "protocol",     mrb_plugin_get_protocol,    MRB_ARGS_NONE());
  mrb_define_method(mrb, plugin_klass, "port",         mrb_plugin_get_port,        MRB_ARGS_NONE());

  FILE *plugin_src = fopen("plugin.rb", "r");
  mrb_load_file(mrb, plugin_src);
  fclose(plugin_src);

  mrb_close(mrb);

  return 0;
}
