#include "config.h"
#include <epan/packet.h>

#include <mruby.h>
#include <mruby/compile.h>
#include "packet-foo.h"

#define FOO_PORT 30000

void proto_register_foo(void)
{
}

void proto_reg_handoff_foo(void)
{
  mrb_state *mrb = mrb_open();

  mrb_plugin_gem_init(mrb);
  FILE *plugin_src = fopen("../plugins/epan/foo/foo_plugin.rb", "r");
  mrb_load_file(mrb, plugin_src);

  mrb_close(mrb);
}
