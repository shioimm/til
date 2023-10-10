#include <string.h>
#include <mruby.h>
#include <mruby/variable.h>
#include <mruby/string.h>
#include <mruby/data.h>
#include <mruby/class.h>

const char *PUNCT_MARK[] = { "!", "?", ":)" };
const int PUNCT_SIZE = sizeof(PUNCT_MARK) / sizeof(char*);

typedef struct {
  uint32_t n;
  size_t   name_len;
  char    *name;
} hello_name;

static void hello_free(mrb_state *mrb, void *data)
{
  hello_name *nm = (hello_name *)data;

  if (nm->name) {
    mrb_free(mrb, nm->name);
  }
  mrb_free(mrb, nm);
}

static struct mrb_data_type mrb_hello_type = { "Hello", hello_free };

static mrb_value mrb_mruby_hello_initialize(mrb_state *mrb, mrb_value self)
{
  mrb_int     n;
  size_t      len;
  char       *name;
  hello_name *datap;

  mrb_get_args(mrb, "si", &name, &len, &n);

  if (n < 0 || n >= PUNCT_SIZE) {
    mrb_raisef(mrb, E_ARGUMENT_ERROR, "invalid argument.");
  }

  datap = (hello_name *)DATA_PTR(self);

  if (datap) {
    mrb_free(mrb, datap);
  }

  mrb_data_init(self, NULL, &mrb_hello_type); // RDataを確保

  datap = mrb_malloc(mrb, sizeof(hello_name));
  datap->n        = n;
  datap->name_len = len;
  datap->name     = (char *)mrb_calloc(mrb, sizeof(char), len + 1);
  memcpy(datap->name, name, len);

  mrb_data_init(self, datap, &mrb_hello_type); // RDataを確保

  return self;
}

static mrb_value mrb_mruby_hello_copy(mrb_state *mrb, mrb_value copy)
{
  mrb_value  src;
  hello_name *nm1, *nm2;

  mrb_get_args(mrb, "o", &src);

  if (mrb_obj_equal(mrb, copy, src)) {
    return copy;
  }

  if (!mrb_obj_is_instance_of(mrb, src, mrb_obj_class(mrb, copy))) {
    mrb_raise(mrb, E_ARGUMENT_ERROR, "wrong argument class");
  }

  nm1 = (hello_name *)DATA_PTR(copy);
  nm2 = (hello_name *)DATA_PTR(src);

  if (!nm1) {
    nm1 = (hello_name *)mrb_malloc(mrb, sizeof(hello_name));
    mrb_data_init(copy, nm1, &mrb_hello_type);
  }
  *nm1 = *nm2;
  nm1->name = (char *)mrb_calloc(mrb, sizeof(char), nm2->name_len + 1);
  memcpy(nm1->name, nm2->name, nm2->name_len);

  return copy;
}

static hello_name *name_get_ptr(mrb_state *mrb, mrb_value name)
{
  hello_name *nm;
  nm = DATA_GET_PTR(mrb, name, &mrb_hello_type, hello_name);

  if (!nm) {
    mrb_raise(mrb, E_ARGUMENT_ERROR, "uninitialized name");
  }

  return nm;
}

static mrb_value mrb_mruby_greeting(mrb_state *mrb, mrb_value self)
{
  mrb_value   hello = mrb_str_new_lit(mrb, "Hello, ");
  hello_name *datap = name_get_ptr(mrb, self);
  mrb_value   name  = mrb_str_new(mrb, datap->name, datap->name_len);

  mrb_str_cat_str(mrb, hello, name);
  mrb_str_cat_str(mrb, hello, mrb_str_new_cstr(mrb, PUNCT_MARK[datap->n]));

  return hello;
}

void mrb_mruby_hello2_gem_init(mrb_state *mrb)
{
  struct RClass *hello_klass = mrb_define_class(mrb, "Hello", mrb->object_class);

  MRB_SET_INSTANCE_TT(hello_klass, MRB_TT_DATA);
  // MRB_TT_DATA (mrb_vtype) = struct RData (C type) = "Data" (Ruby class)

  mrb_define_method(mrb, hello_klass, "initialize",      mrb_mruby_hello_initialize, MRB_ARGS_REQ(2));
  mrb_define_method(mrb, hello_klass, "initialize_copy", mrb_mruby_hello_copy,       MRB_ARGS_REQ(2));
  mrb_define_method(mrb, hello_klass, "greeting",        mrb_mruby_greeting,         MRB_ARGS_NONE());
}

void mrb_mruby_hello2_gem_final(mrb_state *mrb)
{
}
