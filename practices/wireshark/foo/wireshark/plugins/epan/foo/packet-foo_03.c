// ref: https://www.wireshark.org/docs/wsdg_html_chunked/ChDissectAdd.html

#include "config.h"
#include <epan/packet.h>

#define FOO_PORT 30000

static int proto_foo = -1;

static int hf_foo_pdu_type   = -1;
static int hf_foo_flags      = -1;
static int hf_foo_sequenceno = -1;
static int hf_foo_initialip  = -1;

static gint ett_foo = -1;

static int dissect_foo(tvbuff_t *tvb, packet_info *pinfo, proto_tree *tree _U_, void *data _U_)
{
  col_set_str(pinfo->cinfo, COL_PROTOCOL, "FOO");
  col_clear(pinfo->cinfo,COL_INFO);

  proto_item *ti = proto_tree_add_item(tree, proto_foo, tvb, 0, -1, ENC_NA);
  proto_tree *foo_tree = proto_item_add_subtree(ti, ett_foo);

  gint offset = 0;
  proto_tree_add_item(foo_tree, hf_foo_pdu_type,   tvb, offset, 1, ENC_BIG_ENDIAN);
  offset += 1;
  proto_tree_add_item(foo_tree, hf_foo_flags,      tvb, offset, 1, ENC_BIG_ENDIAN);
  offset += 1;
  proto_tree_add_item(foo_tree, hf_foo_sequenceno, tvb, offset, 2, ENC_BIG_ENDIAN);
  offset += 2;
  proto_tree_add_item(foo_tree, hf_foo_initialip,  tvb, offset, 4, ENC_BIG_ENDIAN);
  offset += 4;

  return tvb_captured_length(tvb);
}

void proto_register_foo(void)
{
  // ヘッダフィールド (hf) 情報
  static hf_register_info hf[] = {
    // {
    //   ノードのインデックス,
    //   { 項目のラベル,
    //     表示フィルタの項目名 (省略),
    //     項目のタイプ,
    //     整数型の扱い (BASE_OCT | BASE_DEC | BASE_HEX),
    //     ...,
    //     ...,
    //     ...,
    //     ..., } }
    { &hf_foo_pdu_type,
      { "FOO PDU Type",
        "foo.type",
        FT_UINT8,
        BASE_DEC,
        NULL,
        0x0,
        NULL,
        HFILL } },
    { &hf_foo_flags,
      { "FOO PDU Flags",
        "foo.flags",
        FT_UINT8,
        BASE_HEX,
        NULL,
        0x0,
        NULL,
        HFILL } },
    { &hf_foo_sequenceno,
      { "FOO PDU Sequence Number",
        "foo.seqn",
        FT_UINT16,
        BASE_DEC,
        NULL,
        0x0,
        NULL,
        HFILL } },
    { &hf_foo_initialip,
      { "FOO PDU Initial IP",
        "foo.initialip",
        FT_IPv4,
        BASE_NONE,
        NULL,
        0x0,
        NULL,
        HFILL } },
  };

  // サブツリーのノードの拡張を制御
  static gint *ett[] = { &ett_foo };

  proto_foo = proto_register_protocol (
    "FOO Protocol",
    "FOO",
    "foo"
  );

  proto_register_field_array(proto_foo, hf, array_length(hf));
  proto_register_subtree_array(ett, array_length(ett));
}

void proto_reg_handoff_foo(void)
{
  static dissector_handle_t foo_handle;

  foo_handle = create_dissector_handle(dissect_foo, proto_foo);
  dissector_add_uint("tcp.port", FOO_PORT, foo_handle);
}
