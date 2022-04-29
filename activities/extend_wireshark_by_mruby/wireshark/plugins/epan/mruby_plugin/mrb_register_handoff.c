#include "mrb_register_plugin.c"
#include "mrb_plugin.h"

extern  int phandle;
extern gint ett_state;

extern plugin_t  plugin;
extern subtree_t subtree;

extern int bitmasked_fields_size;
extern int* bit_handles_pool[BIT_HANDLES_POOL_SIZE];
extern bit_handle_t bit_handles[BIT_HANDLES_SIZE];

extern void* hf_descs_pool[HF_DESCS_POOL_SIZE];

static int dissect(tvbuff_t *tvb, packet_info *pinfo, proto_tree *tree _U_, void *data _U_)
{
  col_set_str(pinfo->cinfo, COL_PROTOCOL, plugin.name);
  col_clear(pinfo->cinfo, COL_INFO);

  // WIP: Enhancing the display
  guint8 packet_type = tvb_get_guint8(tvb, 0);
  col_add_fstr(pinfo->cinfo, COL_INFO, subtree.fields[0].cinfo.format,
               val_to_str(packet_type, subtree.fields[0].cinfo.value, subtree.fields[0].cinfo.fallback));

  if (plugin.subtree == 1) {
    proto_item *ti = proto_tree_add_item(tree, phandle, tvb, 0, -1, ENC_NA);
    proto_tree *maintree = proto_item_add_subtree(ti, ett_state);

    // WIP: Enhancing the display
    proto_item_append_text(ti, subtree.fields[0].cinfo.format,
                           val_to_str(packet_type,
                                      subtree.fields[0].cinfo.value,
                                      subtree.fields[0].cinfo.fallback));

    gint offset = 0;
    field_t field;

    for (int i = 0; i < subtree.field_size; i++) {
      field = subtree.fields[i];

      if (field.type == NORMAL) {
        proto_tree_add_item(maintree, field.handle, tvb, offset, field.size, ENC_BIG_ENDIAN);
        offset += field.size;
      } else if (field.type == BITMASKED) {
        int bit_handles_pool_index = 0;

        for (int j = 0; j < bitmasked_fields_size; j++) {
          if (bit_handles[i].symbol == field.symbol) {
            bit_handles_pool_index = bit_handles[i].offset;
            break;
          }
        }
        proto_tree_add_bitmask(maintree, tvb, offset, field.handle, ett_state,
                               &bit_handles_pool[bit_handles_pool_index], ENC_BIG_ENDIAN);
        offset += 1;
      } else if (field.type == BIT) {
        continue;
      }
    }
  }

  return tvb_captured_length(tvb);
}

static void mrb_register_handoff(mrb_state *mrb, mrb_value self)
{
  static dissector_handle_t dhandle;
  dhandle = create_dissector_handle(dissect, phandle);
  mrb_value protocol = mrb_funcall(mrb, mrb_plugin_get_protocol(mrb, self), "to_s", 0);

  dissector_add_uint(mrb_str_to_cstr(mrb, mrb_str_cat_lit(mrb, protocol, ".port")),
                     plugin.port,
                     dhandle);
}
