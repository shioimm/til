# `<mruby/data.h>`
#### `struct mrb_data_type`
```c
typedef struct mrb_data_type {
  const char *struct_name; // data type name
  void (*dfree)(mrb_state *mrb, void*); // data type release functioon pointer
} mrb_data_type;
```
