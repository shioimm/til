// ref: https://www.wireshark.org/docs/wsdg_html_chunked/ChDissectAdd.html

#include "config.h"
#include <epan/packet.h>

#define FOO_PORT 30000

// フラグマスク
#define FOO_START_FLAG      0x01
#define FOO_END_FLAG        0x02
#define FOO_PRIORITY_FLAG   0x04

static int proto_foo = -1;

static int hf_foo_pdu_type   = -1;
static int hf_foo_flags      = -1;
static int hf_foo_sequenceno = -1;
static int hf_foo_initialip  = -1;

static int hf_foo_startflag    = -1;
static int hf_foo_endflag      = -1;
static int hf_foo_priorityflag = -1;

static gint ett_foo = -1;

static const value_string packettypenames[] = {
  { 1, "Initialise" },
  { 2, "Terminate" },
  { 3, "Data" },
  { 0, NULL }
};

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

  static int* const bits[] = {
    &hf_foo_startflag,
    &hf_foo_endflag,
    &hf_foo_priorityflag,
    NULL
  };

  // ビットマスクの追加
  proto_tree_add_bitmask(foo_tree, tvb, offset, hf_foo_flags, ett_foo, bits, ENC_BIG_ENDIAN);
  offset += 1;

  return tvb_captured_length(tvb);
}

void proto_register_foo(void)
{
  static hf_register_info hf[] = {
    { &hf_foo_pdu_type,
      { "FOO PDU Type",
        "foo.type",
        FT_UINT8,
        BASE_DEC,
        VALS(packettypenames),
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
    { &hf_foo_startflag,
      { "FOO PDU Start Flags",
        "foo.flags.start",
        FT_BOOLEAN,
        8, // 8ビット分のビットマスク
        NULL,
        FOO_START_FLAG,
        NULL,
        HFILL } },
    { &hf_foo_endflag,
      { "FOO PDU End Flags",
        "foo.flags.end",
        FT_BOOLEAN,
        8,
        NULL,
        FOO_END_FLAG,
        NULL,
        HFILL } },
    { &hf_foo_priorityflag,
      { "FOO PDU Priority Flags",
        "foo.flags.priority",
        FT_BOOLEAN,
        8,
        NULL,
        FOO_PRIORITY_FLAG,
        NULL,
        HFILL } },
  };

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
