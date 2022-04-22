#include "config.h"
#include <epan/packet.h>

#include <mruby.h>
#include <mruby/array.h>
#include <mruby/class.h>
#include <mruby/compile.h>
#include <mruby/hash.h>
#include <mruby/numeric.h>
#include <mruby/string.h>
#include <mruby/value.h>
#include <mruby/variable.h>

#define MRB_SYM(mrb, name) mrb_symbol_value(mrb_intern_lit(mrb, name))

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

  mrb_value field      = mrb_hash_new(mrb);
  mrb_value label      = mrb_funcall(mrb, args, "fetch", 1, MRB_SYM(mrb, "label"));
  mrb_value filter     = mrb_funcall(mrb, args, "fetch", 1, MRB_SYM(mrb, "filter"));
  mrb_value field_type = mrb_funcall(mrb, args, "fetch", 1, MRB_SYM(mrb, "field_type"));
  mrb_value int_type   = mrb_funcall(mrb, args, "fetch", 1, MRB_SYM(mrb, "int_type"));
  mrb_value size       = mrb_funcall(mrb, args, "fetch", 1, MRB_SYM(mrb, "size"));
  mrb_value desc       = mrb_funcall(mrb, args, "fetch", 2, MRB_SYM(mrb, "desc"), mrb_nil_value());

  if (!mrb_nil_p(desc)) {
    desc = mrb_funcall(mrb, desc, "invert", 0);
    desc = mrb_funcall(mrb, desc, "to_a", 0);
  }

  mrb_hash_set(mrb, field, MRB_SYM(mrb, "label"),      label);
  mrb_hash_set(mrb, field, MRB_SYM(mrb, "filter"),     filter);
  mrb_hash_set(mrb, field, MRB_SYM(mrb, "field_type"), field_type);
  mrb_hash_set(mrb, field, MRB_SYM(mrb, "int_type"),   int_type);
  mrb_hash_set(mrb, field, MRB_SYM(mrb, "size"),       size);
  mrb_hash_set(mrb, field, MRB_SYM(mrb, "desc"),       desc);

  mrb_ary_push(mrb, mrb_iv_get(mrb, self, mrb_intern_lit(mrb, "@fields")), field);

  return field;
}

void mrb_subtree_gem_init(mrb_state *mrb)
{
  struct RClass *subtree_klass = mrb_define_class(mrb, "Subtree", mrb->object_class);
  mrb_define_method(mrb, subtree_klass, "initialize",  mrb_subtree_init,       MRB_ARGS_NONE());
  mrb_define_method(mrb, subtree_klass, "field",       mrb_subtree_add_field,  MRB_ARGS_REQ(1));
  mrb_define_method(mrb, subtree_klass, "fields",      mrb_subtree_get_fields, MRB_ARGS_NONE());
}
