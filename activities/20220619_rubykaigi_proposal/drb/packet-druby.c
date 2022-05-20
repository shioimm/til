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

static gint ett_branch = -1;
static gint ett_node = -1;

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

  // success
  guint32     success_len  = tvb_get_guint32(tvb, *offset, ENC_BIG_ENDIAN);
  proto_tree *success_tree = proto_tree_add_subtree(tree, tvb, *offset, success_len + 4,
                                                    ett_node, NULL, "Success");

  proto_tree_add_item(success_tree, hf_druby_len, tvb, *offset, 4, ENC_NA);
  *offset += 4;
  *offset += 2; // \x04\bを飛ばす

  proto_tree_add_item(success_tree, hf_druby_type, tvb, *offset, 1, ENC_NA);
  *offset += 1;

  // result
  guint32 result_len = tvb_get_guint32(tvb, *offset, ENC_BIG_ENDIAN);
  proto_tree* result_tree = proto_tree_add_subtree(tree, tvb, *offset, result_len + 4,
                                                   ett_node, NULL, "Result");

  proto_tree_add_item(result_tree, hf_druby_len, tvb, *offset, 4, ENC_NA);
  *offset += 4;
  *offset += 2; // \x04\bを飛ばす

  guint8 result_type = tvb_get_guint8(tvb, *offset);

  if (result_type == 'I') { // インスタンス変数の場合
    *offset += 1; // Iを飛ばす
    result_type = tvb_get_guint8(tvb, *offset);
  }

  proto_tree_add_item(result_tree, hf_druby_type, tvb, *offset, 1, ENC_NA);
  *offset += 1;

  *offset += 1; // \x10を飛ばす
  int result_value_len = 0;

  if (result_type == '"') { // 文字列の場合
    result_value_len = result_len - 10;
  }

  proto_tree_add_item(result_tree, hf_type_handle(result_type), tvb, *offset, result_value_len, ENC_NA);
  *offset += result_value_len;
}

#define BETWEEN(v, b1, b2) (((v) >= (b1)) && ((v) <= (b2)))

void get_druby_integer(tvbuff_t* tvb, guint offset, gint32* value)
{
  gint8 c;
  c = (tvb_get_gint8(tvb, offset) ^ 128) - 128;
  if (c == 0) {
    *value = 0;
    return;
  }
  if (c >= 4) {
    *value = c - 5;
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
    return;
  }
  if (c < -6) {
    *value = c + 5;
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
    return;
  }
}

static void dissect_drb_request(tvbuff_t* tvb, packet_info* pinfo, proto_tree* tree, guint* offset)
{
  col_append_str(pinfo->cinfo, COL_INFO, "dRuby request");

  // ref
  guint32     ref_len  = tvb_get_guint32(tvb, *offset, ENC_BIG_ENDIAN);
  proto_tree *ref_tree = proto_tree_add_subtree(tree, tvb, *offset, ref_len + 4,
                                                ett_node, NULL, "Ref");

  proto_tree_add_item(ref_tree, hf_druby_len, tvb, *offset, 4, ENC_NA);
  *offset += 4;
  *offset += 2; // \x04\bを飛ばす

  proto_tree_add_item(ref_tree, hf_druby_string, tvb, *offset, 1, ENC_NA);
  *offset += 1;

  // message
  guint32     message_len = tvb_get_guint32(tvb, *offset, ENC_BIG_ENDIAN);
  proto_tree *message_tree = proto_tree_add_subtree(tree, tvb, *offset, message_len + 4,
                                                    ett_node, NULL, "Message");

  proto_tree_add_item(message_tree, hf_druby_len, tvb, *offset, 4, ENC_NA);
  *offset += 4;
  *offset += 2; // \x04\bを飛ばす

  guint8 message_type = tvb_get_guint8(tvb, *offset);

  if (message_type == 'I') { // インスタンス変数の場合
    *offset += 1; // Iを飛ばす
    message_type = tvb_get_guint8(tvb, *offset);
  }

  proto_tree_add_item(message_tree, hf_druby_type, tvb, *offset, 1, ENC_NA);
  *offset += 1;

  *offset += 1; // \x10を飛ばす

  int message_value_len = 0;

  if (message_type == '"') { // 文字列の場合
    message_value_len = message_len - 10;
  }

  proto_tree_add_item(message_tree, hf_druby_string, tvb, *offset, message_value_len, ENC_NA);
  *offset += message_value_len;

  if (message_type == '"') { // 文字列の場合
    *offset += 5; // :EFを飛ばす
  }

  // args_size
  guint32     args_size_len  = tvb_get_guint32(tvb, *offset, ENC_BIG_ENDIAN);
  proto_tree *args_size_tree = proto_tree_add_subtree(tree, tvb, *offset, args_size_len + 4,
                                                      ett_node, NULL, "Args size");

  proto_tree_add_item(args_size_tree, hf_druby_len, tvb, *offset, 4, ENC_NA);
  *offset += 4;
  *offset += 2; // \x04\bを飛ばす

  proto_tree_add_item(args_size_tree, hf_druby_type, tvb, *offset, 1, ENC_NA);
  *offset += 1;

  gint32 args_size;
  get_druby_integer(tvb, *offset, &args_size);

  proto_tree_add_item(args_size_tree, hf_druby_integer, tvb, *offset, 1, ENC_NA);
  *offset += 1;

  // args
  guint32     args_len  = tvb_get_guint32(tvb, *offset, ENC_BIG_ENDIAN);
  proto_tree *args_tree = proto_tree_add_subtree(tree, tvb, *offset, 4 + args_len,
                                                 ett_node, NULL, "Args");

  gchar      *arg_n_label;
  guint32     args_lengths[args_size];
  proto_tree *args_trees[args_size];

  int    arg_value_lengths[args_size];
  guint8 arg_types[args_size];

  for (gint32 i = 0; i < args_size; i++) {
    arg_n_label = wmem_strdup_printf(pinfo->pool, "Arg (%d)", i + 1);

    args_lengths[i] = tvb_get_guint32(tvb, *offset, ENC_BIG_ENDIAN);
    args_trees[i]   = proto_tree_add_subtree(args_tree, tvb, *offset, args_lengths[i] + 4,
                                             ett_node, NULL, arg_n_label);

    proto_tree_add_item(args_trees[i], hf_druby_len, tvb, *offset, 4, ENC_NA);
    *offset += 4;
    *offset += 2; // \x04\bを飛ばす

    arg_types[i] = tvb_get_guint8(tvb, *offset);

    if (arg_types[i] == 'I') { // インスタンス変数の場合
      *offset += 1; // Iを飛ばす
      arg_types[i] = tvb_get_guint8(tvb, *offset);
    }

    proto_tree_add_item(args_trees[i], hf_druby_type, tvb, *offset, 1, ENC_NA);
    *offset += 1;

    *offset += 1; // \x10を飛ばす

    arg_value_lengths[i] = 0;

    if (arg_types[i] == '"') { // 文字列の場合
      arg_value_lengths[i] = args_lengths[i] - 10;
    }

    proto_tree_add_item(args_trees[i], hf_type_handle(arg_types[i]), tvb,
                        *offset, arg_value_lengths[i], ENC_NA);
    *offset += arg_value_lengths[i];

    if (arg_types[i] == '"') { // 文字列の場合
      *offset += 5; // :EFを飛ばす
    }
  }

  // block
  guint32     block_len  = tvb_get_guint32(tvb, *offset, ENC_BIG_ENDIAN);
  proto_tree *block_tree = proto_tree_add_subtree(tree, tvb, *offset, block_len + 4,
                           ett_node, NULL, "Block");

  proto_tree_add_item(block_tree, hf_druby_len, tvb, *offset, 4, ENC_NA);
  *offset += 4;
  *offset += 2; // \x04\bを飛ばす

  proto_tree_add_item(block_tree, hf_druby_type, tvb, *offset, 1, ENC_NA);
  *offset += 1;
}

static int dissect_druby(tvbuff_t *tvb, packet_info *pinfo, proto_tree *tree _U_, void *data _U_)
{
  col_set_str(pinfo->cinfo, COL_PROTOCOL, "dRuby");
  col_clear(pinfo->cinfo,COL_INFO);

  gint offset = 0;
  proto_item *ti = proto_tree_add_item(tree, proto_druby, tvb, 0, -1, ENC_NA);
  proto_tree *drb_tree = proto_item_add_subtree(ti, ett_branch);

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
      { "Data size", "druby.length", FT_UINT32, BASE_DEC, NULL, 0x00, NULL, HFILL, } },
    { &hf_druby_type,
      { "Data type", "druby.type", FT_UINT8, BASE_HEX, VALS(druby_types), 0x00, NULL, HFILL } },
    { &hf_druby_integer,
      { "Value", "druby.int", FT_INT32, BASE_DEC, NULL, 0x00, NULL, HFILL } },
    { &hf_druby_string,
      { "Value", "druby.string", FT_STRING, BASE_NONE, NULL, 0x00, NULL, HFILL } },
  };

  static gint *ett[] = {
    &ett_branch,
    &ett_node,
  };

  proto_druby = proto_register_protocol("druby Protocol", "druby", "drby");
  proto_register_field_array(proto_druby, hf, array_length(hf));
  proto_register_subtree_array(ett, array_length(ett));
}

void proto_reg_handoff_druby(void)
{
  static dissector_handle_t druby_handle;

  druby_handle = create_dissector_handle(dissect_druby, proto_druby);
  dissector_add_uint("tcp.port", DRUBY_PORT, druby_handle);
}
