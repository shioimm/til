#include "config.h"
#include <epan/packet.h>

#include <mruby.h>
#include <mruby/compile.h>
#include <mruby/class.h>
#include <mruby/numeric.h>
#include <mruby/variable.h>
#include <mruby/value.h>
#include <mruby/string.h>

static mrb_value mrb_subtree_add_field(mrb_state *mrb, mrb_value self)
{
  // WIP
  return mrb_nil_value();
}

void mrb_subtree_gem_init(mrb_state *mrb)
{
  struct RClass *subtree_klass = mrb_define_class(mrb, "SubTree", mrb->object_class);
  mrb_define_method(mrb, subtree_klass, "add_field", mrb_subtree_add_field, MRB_ARGS_NONE());
}
