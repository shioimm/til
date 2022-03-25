# `mrb_value`
- mrubyのすべてのオブジェクトを表現するための型

```c
union mrb_value_union {
  void    *p; // RData構造体へのポインタ
  mrb_int  i;
  mrb_sym  sym;
};

typedef struct mrb_value {
  union mrb_value_union value;
  enum  mrb_type        tt;
} mrb_value;
```
