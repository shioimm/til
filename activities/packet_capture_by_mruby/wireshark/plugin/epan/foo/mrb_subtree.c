#include "config.h"
#include <epan/packet.h>

#include <mruby.h>
#include <mruby/array.h>
#include <mruby/compile.h>
#include <mruby/class.h>
#include <mruby/numeric.h>
#include <mruby/variable.h>
#include <mruby/value.h>
#include <mruby/string.h>

static mrb_value mrb_subtree_init(mrb_state *mrb, mrb_value self)
{
  mrb_iv_set(mrb, self, mrb_intern_lit(mrb, "@fields"), mrb_ary_new(mrb));

  return self;
}

static mrb_value mrb_subtree_get_fields(mrb_state *mrb, mrb_value self)
{
  return mrb_iv_get(mrb, self, mrb_intern_lit(mrb, "@fields"));
}

static mrb_value mrb_subtree_add_field(mrb_state *mrb, mrb_value self)
{
  mrb_value args;
  mrb_get_args(mrb, "H", &args);
  mrb_value label      = mrb_funcall(mrb, args, "fetch", 1, mrb_symbol_value(mrb_intern_lit(mrb, "label")));
  mrb_value filter     = mrb_funcall(mrb, args, "fetch", 1, mrb_symbol_value(mrb_intern_lit(mrb, "filter")));
  mrb_value field_type = mrb_funcall(mrb, args, "fetch", 1, mrb_symbol_value(mrb_intern_lit(mrb, "field_type")));
  mrb_value int_type   = mrb_funcall(mrb, args, "fetch", 1, mrb_symbol_value(mrb_intern_lit(mrb, "int_type")));

  mrb_value field_members[] = { label, filter, field_type, int_type };
  mrb_value field = mrb_ary_new_from_values(mrb, 4, field_members);
  mrb_ary_push(mrb, mrb_iv_get(mrb, self, mrb_intern_lit(mrb, "@fields")), field);

  return field;
}

void mrb_subtree_gem_init(mrb_state *mrb)
{
  struct RClass *subtree_klass = mrb_define_class(mrb, "SubTree", mrb->object_class);
  mrb_define_method(mrb, subtree_klass, "initialize",  mrb_subtree_init,       MRB_ARGS_NONE());
  mrb_define_method(mrb, subtree_klass, "field",       mrb_subtree_add_field,  MRB_ARGS_REQ(1));
  mrb_define_method(mrb, subtree_klass, "fields",      mrb_subtree_get_fields, MRB_ARGS_NONE());
}
