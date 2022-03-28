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

  mrb_protocol_gem_init(mrb);
  mrb_value proto = mrb_load_string(mrb, "Protocol.new('FOO', :tcp, 30000)");
  mrb_p(mrb, proto);

  mrb_register_protocol(proto);
  mrb_register_handoff(proto);

  mrb_close(mrb);
}
