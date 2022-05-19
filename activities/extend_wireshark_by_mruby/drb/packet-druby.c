// WIP
// plugin/epan/druby/packet-druby.c
// ref: https://gitlab.com/wireshark/wireshark/-/blob/master/epan/dissectors/packet-drb.c
// ref: https://gitlab.com/wireshark/wireshark/-/blob/master/epan/dissectors/file-rbm.c
#include "config.h"
#include <epan/packet.h>
#include <stdio.h>

#define DRUBY_PORT 8080

static int proto_druby = -1;

static int hf_druby_len = -1;
static int hf_druby_type = -1;
static int hf_druby_integer = -1;
static int hf_druby_string = -1;

static gint ett_druby = -1;
static gint ett_ref = -1;

static gint ett_variable = -1;

static const value_string druby_types[] = {
  { '0', "nil" },
  { 'T', "true" },
  { 'F', "false" },
  { 'i', "Integer" },
  { ':', "Symbol" },
  { '"', "String" },
  { 'I', "Instance variable" },
  { '[', "Array" },
  { '{', "Hash" },
  { 'f', "Double" },
  { 'c', "Class" },
  { 'm', "Module" },
  { 'S', "Struct" },
  { '/', "Regexp" },
  { 'o', "Object" },
  { 'C', "UserClass" },
  { 'e', "Extended_object" },
  { ';', "Symbol link" },
  { '@', "Object link" },
  { 'u', "DRb::DRbObject" },
  { ',', "DRb address" },
  {0, NULL}
};

static int hf_type_handle(char c)
{
  int index = 0;
  switch (c) {
    case '0':
      break;
    case 'T':
      break;
    case 'F':
      break;
    case 'i':
      index = hf_druby_integer;
      break;
    case ':':
      break;
    case '"':
      index = hf_druby_string;
      break;
    case 'I':
      break;
    case '[':
      break;
    case '{':
      break;
    case ';':
    case '@':
      break;
    case 'f':
      break;
    case 'c':
      break;
    case 'm':
      break;
    case 'S':
      break;
    case '/':
      break;
    case 'u':
      break;
    case ',':
      break;
    case 'o':
      break;
    case 'C':
      break;
    case 'e':
      break;
    default:
      break;
  }
  return index;
}

static void dissect_drb_response(tvbuff_t* tvb, packet_info* pinfo, proto_tree* tree, guint* offset)
{
  col_append_str(pinfo->cinfo, COL_INFO, "dRuby response");

  guint32 succ_len;
  proto_tree* succ_tree;

  succ_len = tvb_get_guint32(tvb, *offset, ENC_BIG_ENDIAN);
  succ_tree = proto_tree_add_subtree(tree, tvb, *offset, 4 + succ_len, ett_ref, NULL, "Success");
  proto_tree_add_item(succ_tree, hf_druby_len, tvb, *offset, 4, ENC_NA);
  *offset += 4;

  *offset += 2; // \x04\bを飛ばす
  proto_tree_add_item(succ_tree, hf_druby_type, tvb, *offset, 1, ENC_NA);
  *offset += 1;

  guint32 res_len;
  proto_tree* res_tree;

  res_len = tvb_get_guint32(tvb, *offset, ENC_BIG_ENDIAN);
  res_tree = proto_tree_add_subtree(tree, tvb, *offset, 4 + res_len, ett_ref, NULL, "Result");
  proto_tree_add_item(res_tree, hf_druby_len, tvb, *offset, 4, ENC_NA);
  *offset += 4;

  *offset += 2; // \x04\bを飛ばす
  *offset += 1; // Iを飛ばす
  proto_tree_add_item(res_tree, hf_druby_type, tvb, *offset, 1, ENC_NA);
  guint8 subtype = tvb_get_guint8(tvb, *offset);
  *offset += 1;
  *offset += 1; // \x10を飛ばす

  int body_len = res_len - 10;
  proto_tree_add_item(res_tree, hf_type_handle(subtype), tvb, *offset, body_len, ENC_NA);
  *offset += body_len;
}

#define BETWEEN(v, b1, b2) (((v) >= (b1)) && ((v) <= (b2)))

void get_druby_integer(tvbuff_t* tvb, guint offset, gint32* value, gint* len)
{
  gint8 c;
  c = (tvb_get_gint8(tvb, offset) ^ 128) - 128;
  if (c == 0) {
    *value = 0;
    *len = 1;
    return;
  }
  if (c >= 4) {
    *value = c - 5;
    *len = 1;
    return;
  }
  if (BETWEEN(c, 1, 3)) {
    gint i;
    *value = 0;
    guint8 byte;
    for (i = 0; i < c; i++) {
      byte = tvb_get_guint8(tvb, offset + 1 + i);
      *value |= (byte << (8 * i));
    }
    *len = (c + 1);
    return;
  }
  if (c < -6) {
    *value = c + 5;
    *len = 1;
    return;
  }
  if (BETWEEN(c, -5, -1)) {
    gint i;
    *value = -1;
    guint8 byte;
    gint32 a;
    gint32 b;
    for (i = 0; i < -c; i++) {
      byte = tvb_get_guint8(tvb, offset + 1 + i);
      a = ~(0xff << (8*i));
      b = byte << (8*i);
      *value = ((*value & a) | b);
    }
    *len = (-c + 1);
    return;
  }
}

static void dissect_drb_request(tvbuff_t* tvb, packet_info* pinfo, proto_tree* tree, guint* offset)
{
  col_append_str(pinfo->cinfo, COL_INFO, "dRuby request");

  guint32 ref_len;
  proto_tree* ref_tree;

  ref_len = tvb_get_guint32(tvb, *offset, ENC_BIG_ENDIAN);
  ref_tree = proto_tree_add_subtree(tree, tvb, *offset, 4 + ref_len, ett_ref, NULL, "Ref");
  proto_tree_add_item(ref_tree, hf_druby_len, tvb, *offset, 4, ENC_NA);
  *offset += 4;
  *offset += 2; // \x04\bを飛ばす
  proto_tree_add_item(ref_tree, hf_druby_string, tvb, *offset, 1, ENC_NA);
  *offset += 1;

  guint32 msgid_len;
  proto_tree* msgid_tree;

  msgid_len = tvb_get_guint32(tvb, *offset, ENC_BIG_ENDIAN);
  msgid_tree = proto_tree_add_subtree(tree, tvb, *offset, 4 + ref_len, ett_ref, NULL, "Msg ID");
  proto_tree_add_item(msgid_tree, hf_druby_len, tvb, *offset, 4, ENC_NA);
  *offset += 4;
  *offset += 2; // \x04\bを飛ばす
  *offset += 1; // Iを飛ばす
  proto_tree_add_item(msgid_tree, hf_druby_type, tvb, *offset, 1, ENC_NA);
  *offset += 1;
  *offset += 1; // \x10を飛ばす

  int body_len = msgid_len - 10;
  proto_tree_add_item(msgid_tree, hf_druby_string, tvb, *offset, body_len, ENC_NA);
  *offset += body_len;
  *offset += 5; // :EFを飛ばす

  gint32 nargs;
  gint len;

  get_druby_integer(tvb, *offset + 4 + 3, &nargs, &len);

  guint32 arglen_len;
  proto_tree* arglen_tree;

  arglen_len = tvb_get_guint32(tvb, *offset, ENC_BIG_ENDIAN);
  arglen_tree = proto_tree_add_subtree(tree, tvb, *offset, 4 + arglen_len, ett_ref, NULL, "Args length");
  proto_tree_add_item(arglen_tree, hf_druby_len, tvb, *offset, 4, ENC_NA);
  *offset += 4;
  *offset += 2; // \x04\bを飛ばす
  proto_tree_add_item(arglen_tree, hf_druby_type, tvb, *offset, 1, ENC_NA);
  *offset += 1;
  proto_tree_add_item(arglen_tree, hf_druby_integer, tvb, *offset, 1, ENC_NA);
  *offset += 1;

  guint32 arg_len;
  proto_tree* arg_tree;

  arg_len = tvb_get_guint32(tvb, *offset, ENC_BIG_ENDIAN);
  arg_tree = proto_tree_add_subtree(tree, tvb, *offset, 4 + arg_len, ett_ref, NULL, "Args");

  gchar* loop_label;
  guint32 args_lengthes[nargs];
  proto_tree* args_trees[nargs];
  int arg_body_lengthes[nargs];
  guint8 arg_subtypes[nargs];

  for (gint32 i = 0; i < nargs; i++) {
    loop_label = wmem_strdup_printf(pinfo->pool, "Arg (%d)", i + 1);

    args_lengthes[i] = tvb_get_guint32(tvb, *offset, ENC_BIG_ENDIAN);
    args_trees[i] = proto_tree_add_subtree(arg_tree, tvb, *offset, 4 + args_lengthes[i], ett_ref, NULL, loop_label);
    proto_tree_add_item(args_trees[i], hf_druby_len, tvb, *offset, 4, ENC_NA);
    *offset += 4;
    *offset += 2; // \x04\bを飛ばす
    *offset += 1; // Iを飛ばす

    proto_tree_add_item(args_trees[i], hf_druby_type, tvb, *offset, 1, ENC_NA);
    arg_subtypes[i] = tvb_get_guint8(tvb, *offset);
    *offset += 1;
    *offset += 1; // \x10を飛ばす

    arg_body_lengthes[i] = args_lengthes[i] - 10;
    proto_tree_add_item(args_trees[i], hf_type_handle(arg_subtypes[i]), tvb, *offset, arg_body_lengthes[i], ENC_NA);
    *offset += arg_body_lengthes[i];
    *offset += 5; // :EFを飛ばす
  }

  guint32 bklen_len;
  proto_tree* bklen_tree;

  bklen_len = tvb_get_guint32(tvb, *offset, ENC_BIG_ENDIAN);
  bklen_tree = proto_tree_add_subtree(tree, tvb, *offset, 4 + bklen_len, ett_ref, NULL, "Block");
  proto_tree_add_item(bklen_tree, hf_druby_len, tvb, *offset, 4, ENC_NA);
  *offset += 4;
  *offset += 2; // \x04\bを飛ばす
  proto_tree_add_item(bklen_tree, hf_druby_type, tvb, *offset, 1, ENC_NA);
  *offset += 1;
}

static int dissect_druby(tvbuff_t *tvb, packet_info *pinfo, proto_tree *tree _U_, void *data _U_)
{
  col_set_str(pinfo->cinfo, COL_PROTOCOL, "druby");
  col_clear(pinfo->cinfo,COL_INFO);

  gint offset = 0;
  proto_item *ti = proto_tree_add_item(tree, proto_druby, tvb, 0, -1, ENC_NA);
  proto_tree *drb_tree = proto_item_add_subtree(ti, ett_druby);

  guint8 type = tvb_get_guint8(tvb, 6);
  if (type == 'T' || type == 'F') {
    dissect_drb_response(tvb, pinfo, drb_tree, &offset);
  } else {
    dissect_drb_request(tvb, pinfo, drb_tree, &offset);
 }

  return tvb_captured_length(tvb);
}

void proto_register_druby(void)
{
  static hf_register_info hf[] = {
    { &hf_druby_len,
      { "Length", "druby.length", FT_UINT32, BASE_DEC, NULL, 0x00, NULL, HFILL, } },
    { &hf_druby_type,
      { "Type", "druby.type", FT_UINT8, BASE_HEX, VALS(druby_types), 0x00, NULL, HFILL } },
    { &hf_druby_integer,
      { "Value", "druby.int", FT_INT32, BASE_DEC, NULL, 0x00, NULL, HFILL } },
    { &hf_druby_string,
      { "Value", "druby.string", FT_STRING, BASE_NONE, NULL, 0x00, NULL, HFILL } },
  };

  static gint *ett[] = {
    &ett_druby,
    &ett_ref,
    &ett_variable
  };

  proto_druby = proto_register_protocol("dRuby Protocol", "druby", "drby");
  proto_register_field_array(proto_druby, hf, array_length(hf));
  proto_register_subtree_array(ett, array_length(ett));
}

void proto_reg_handoff_druby(void)
{
  static dissector_handle_t druby_handle;

  druby_handle = create_dissector_handle(dissect_druby, proto_druby);
  dissector_add_uint("tcp.port", DRUBY_PORT, druby_handle);
}
