#include "mrb_register_handoff.c"

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

mrb_value mrb_plugin_get_name(mrb_state *mrb, mrb_value self)
{
  return mrb_iv_get(mrb, self, mrb_intern_lit(mrb, "@name"));
}

mrb_value mrb_plugin_get_filter_name(mrb_state *mrb, mrb_value self)
{
  return mrb_iv_get(mrb, self, mrb_intern_lit(mrb, "@filter_name"));
}

mrb_value mrb_plugin_get_protocol(mrb_state *mrb, mrb_value self)
{
  return mrb_iv_get(mrb, self, mrb_intern_lit(mrb, "@protocol"));
}

mrb_value mrb_plugin_get_port(mrb_state *mrb, mrb_value self)
{
  return mrb_iv_get(mrb, self, mrb_intern_lit(mrb, "@port"));
}

mrb_value mrb_plugin_add_subtree(mrb_state *mrb, mrb_value self)
{
  mrb_value mrb_subtree = mrb_load_string(mrb, "Subtree.new");
  mrb_iv_set(mrb, self, mrb_intern_lit(mrb, "@subtree"), mrb_subtree);
  mrb_iv_set(mrb, mrb_subtree, mrb_intern_lit(mrb, "@plugin"), self);

  plugin.subtree = 1;
  return mrb_subtree;
}

static mrb_value mrb_plugin_dissect(mrb_state *mrb, mrb_value self)
{
  mrb_value blk;
  mrb_get_args(mrb, "|&", &blk);

  if (!mrb_nil_p(blk)) {
    mrb_value mrb_subtree = mrb_funcall(mrb, self, "add_subtree", 0);
    mrb_yield(mrb, blk, mrb_subtree);
  }

  mrb_register_plugin(mrb, self);
  mrb_register_handoff(mrb, self);

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
