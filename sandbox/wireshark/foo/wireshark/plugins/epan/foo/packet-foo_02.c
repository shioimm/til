// ref: https://www.wireshark.org/docs/wsdg_html_chunked/ChDissectAdd.html

#include "config.h"
#include <epan/packet.h>

#define FOO_PORT 30000

static int proto_foo = -1;

static int dissect_foo(tvbuff_t *tvb, packet_info *pinfo, proto_tree *tree _U_, void *data _U_)
{
  col_set_str(pinfo->cinfo, COL_PROTOCOL, "FOO");
  col_clear(pinfo->cinfo,COL_INFO);

  // proto_tree_add_item - デコード結果を格納するサブツリーの追加
  proto_item *ti = proto_tree_add_item(tree, proto_foo, tvb, 0, -1, ENC_NA);

  return tvb_captured_length(tvb);
}

void proto_register_foo(void)
{
  proto_foo = proto_register_protocol (
    "FOO Protocol",
    "FOO",
    "foo"
  );
}

void proto_reg_handoff_foo(void)
{
  static dissector_handle_t foo_handle;

  foo_handle = create_dissector_handle(dissect_foo, proto_foo);
  dissector_add_uint("tcp.port", FOO_PORT, foo_handle);
}
