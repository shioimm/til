#include "mrb_plugin.h"

static int hf_packet_type(char *name)
{
  if (strcmp(name, "NORMAL") == 0) {
    return NORMAL;
  } else if (strcmp(name, "BITMASKED") == 0) {
    return BITMASKED;
  } else if (strcmp(name, "BIT") == 0) {
    return BIT;
  }

  return 0;
}

static int hf_field_type(char *name)
{
  if (strcmp(name, "FT_UINT8") == 0) {
    return FT_UINT8;
  } else if (strcmp(name, "FT_UINT16") == 0) {
    return FT_UINT16;
  } else if (strcmp(name, "FT_IPv4") == 0) {
    return FT_IPv4;
  } else if (strcmp(name, "FT_BOOLEAN") == 0) {
    return FT_BOOLEAN;
  }

  return 0;
}

static int hf_display(char *name)
{
  if (strcmp(name, "BASE_DEC") == 0) {
    return BASE_DEC;
  } else if (strcmp(name, "BASE_HEX") == 0) {
    return BASE_HEX;
  } else if (strcmp(name, "BASE_NONE") == 0) {
    return BASE_NONE;
  } else {
    atoi(name);
  }

  return 0;
}

static void mrb_register_plugin(mrb_state *mrb, mrb_value self)
{
  phandle = proto_register_protocol(plugin.name, plugin.name, plugin.filter_name);

  if (plugin.subtree == 1) {
    mrb_value mrb_subtree = mrb_iv_get(mrb, self, mrb_intern_lit(mrb, "@subtree"));
    mrb_value mrb_fields  = mrb_funcall(mrb, mrb_subtree, "fields", 0);
    subtree.field_size    = (int)RARRAY_LEN(mrb_funcall(mrb, mrb_subtree, "fields", 0));

    hf_register_info *hf = malloc(sizeof(hf_register_info) * subtree.field_size);

    int bit_fields_size = 0;

    for (int i = 0; i < subtree.field_size; i++) {
      mrb_value mrb_field = mrb_funcall(mrb, mrb_fields, "at", 1, mrb_int_value(mrb, i));

      mrb_value mrb_hf_type       = mrb_funcall(mrb, mrb_field, "fetch", 1, MRB_SYM(mrb, "type"));
      mrb_value mrb_hf_symbol     = mrb_funcall(mrb, mrb_field, "fetch", 1, MRB_SYM(mrb, "symbol"));
      mrb_value mrb_hf_name       = mrb_funcall(mrb, mrb_field, "fetch", 1, MRB_SYM(mrb, "label"));
      mrb_value mrb_hf_abbrev     = mrb_funcall(mrb, mrb_field, "fetch", 1, MRB_SYM(mrb, "filter"));
      mrb_value mrb_hf_field_type = mrb_funcall(mrb, mrb_field, "fetch", 1, MRB_SYM(mrb, "field_type"));
      mrb_value mrb_hf_int_type   = mrb_funcall(mrb, mrb_field, "fetch", 1, MRB_SYM(mrb, "int_type"));
      mrb_value mrb_hf_size       = mrb_funcall(mrb, mrb_field, "fetch", 1, MRB_SYM(mrb, "size"));
      mrb_value mrb_hf_descs      = mrb_funcall(mrb, mrb_field, "fetch", 1, MRB_SYM(mrb, "desc"));
      mrb_value mrb_hf_bitmask    = mrb_funcall(mrb, mrb_field, "fetch", 1, MRB_SYM(mrb, "bitmask"));

      char *hf_name   = malloc(sizeof(char) * mrb_fixnum(mrb_funcall(mrb, mrb_hf_name, "size", 0)));
      char *hf_abbrev = malloc(sizeof(char) * mrb_fixnum(mrb_funcall(mrb, mrb_hf_abbrev, "size", 0)));

      value_string *hf_desc;

      if (!mrb_nil_p(mrb_hf_descs)) {
        mrb_value mrb_hf_desc_size = mrb_funcall(mrb, mrb_hf_descs, "size", 0);
        hf_desc = malloc(sizeof(value_string) * mrb_fixnum(mrb_hf_desc_size));

        for (int hf_desc_i = 0; hf_desc_i < mrb_fixnum(mrb_hf_desc_size); hf_desc_i++) {
          mrb_value mrb_hf_desc = mrb_funcall(mrb, mrb_hf_descs, "fetch", 1, mrb_fixnum_value(hf_desc_i));
          mrb_value mrb_hf_desc_k = mrb_funcall(mrb, mrb_hf_desc, "fetch", 1, mrb_fixnum_value(0));
          mrb_value mrb_hf_desc_v = mrb_funcall(mrb, mrb_hf_desc, "fetch", 1, mrb_fixnum_value(1));
          mrb_hf_desc_k = mrb_funcall(mrb, mrb_hf_desc_k, "to_s", 0);

          guint32 hf_desc_val = (guint32)mrb_fixnum(mrb_hf_desc_v);
          gchar *hf_desc_str = malloc(sizeof(gchar) * mrb_fixnum(mrb_funcall(mrb, mrb_hf_desc_k, "size", 0)));
          strcpy(hf_desc_str, mrb_str_to_cstr(mrb, mrb_hf_desc_k));

          hf_desc[hf_desc_i].value  = hf_desc_val;
          hf_desc[hf_desc_i].strptr = hf_desc_str;
        }
      }

      strcpy(hf_name, mrb_str_to_cstr(mrb, mrb_hf_name));
      strcpy(hf_abbrev, mrb_str_to_cstr(mrb, mrb_hf_abbrev));

      subtree.fields[i].handle = -1;
      subtree.fields[i].size   = (int)mrb_fixnum(mrb_hf_size);
      subtree.fields[i].symbol = mrb_obj_to_sym(mrb, mrb_hf_symbol);
      subtree.fields[i].type   = hf_packet_type(mrb_str_to_cstr(mrb, mrb_hf_type));

      hf[i].p_id = &subtree.fields[i].handle;
      hf[i].hfinfo.name     = hf_name;
      hf[i].hfinfo.abbrev   = hf_abbrev;
      hf[i].hfinfo.type     = hf_field_type(mrb_str_to_cstr(mrb, mrb_hf_field_type));
      hf[i].hfinfo.display  = hf_display(mrb_str_to_cstr(mrb, mrb_hf_int_type));
      hf[i].hfinfo.strings  = !mrb_nil_p(mrb_hf_descs) ? VALS(hf_desc) : NULL;
      hf[i].hfinfo.bitmask  = mrb_fixnum(mrb_hf_bitmask);
      hf[i].hfinfo.blurb    = NULL;
      hf[i].hfinfo.id       = -1;
      hf[i].hfinfo.parent   = 0;
      hf[i].hfinfo.ref_type = HF_REF_TYPE_NONE;
      hf[i].hfinfo.same_name_prev_id = -1;
      hf[i].hfinfo.same_name_next    = NULL;

      if (subtree.fields[i].type == BITMASKED) bitmasked_fields_size++;
      if (subtree.fields[i].type == BIT) bit_fields_size++;
    }

    int bitmasked_field_indexes[bitmasked_fields_size];
    int bit_field_indexes[bit_fields_size];
    int bmfield_current_index = 0;
    int bfield_current_index  = 0;

    for (int i = 0; i < subtree.field_size; i++) {
      field_t field = subtree.fields[i];

      if (field.type == NORMAL) continue;

      if (field.type == BITMASKED) {
        bitmasked_field_indexes[bmfield_current_index] = i;
        bmfield_current_index++;
      }
      if (field.type == BIT) {
        bit_field_indexes[bfield_current_index] = i;
        bfield_current_index++;
      }
    }

    for (int i = 0; i < bitmasked_fields_size; i++) {
      field_t bmfield = subtree.fields[bitmasked_field_indexes[i]];
      int bfield_size = 0;

      for (int j = 0; j < bit_fields_size; j++) {
        if (subtree.fields[bit_field_indexes[j]].symbol == bmfield.symbol) bfield_size++;
      }

      bit_handles[i].symbol = bmfield.symbol;
      bit_handles[i].size   = bfield_size;
      int offset = i > 0 ? bit_handles[i - 1].offset + bit_handles[i - 1].size + 1 : 0;
      bit_handles[i].offset = offset;
    }

    int bit_handles_pools_index = 0;

    for (int i = 0; i < bitmasked_fields_size; i++) {
      for (int j = 0; j < bit_fields_size; j++) {
        if (subtree.fields[bit_field_indexes[j]].symbol == bit_handles[i].symbol) {
          bit_handles_pool[bit_handles[i].offset + bit_handles_pools_index] =
            &subtree.fields[bit_field_indexes[j]].handle;
          bit_handles_pools_index++;
        }
      }
      bit_handles_pool[bit_handles[i].offset + bit_handles[i].size] = NULL;
    }

    static gint *ett[] = { &ett_state };

    proto_register_field_array(phandle, hf, subtree.field_size);
    proto_register_subtree_array(ett, array_length(ett));
  }
}
