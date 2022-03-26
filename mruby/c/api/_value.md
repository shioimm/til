# 値
#### RVALUE構造体 -> `mrb_value`
- RVALUE構造体 - `mrb_value`に紐付けられた実際のデータを管理する構造体

```c
MRB_INLINE mrb_value
mrb_obj_value(void *p);
```

#### `mrb_value` -> RVALUE構造体

```c
struct RString*
mrb_str_ptr(mrb_value val);

struct RArray*
mrb_ary_ptr(mrb_value val);

struct RHash*
mrb_hash_ptr(mrb_value val);

struct RProc*
mrb_proc_ptr(mrb_value val);

struct RObject*
mrb_object_ptr(mrb_value val);

struct RClass*
mrb_class_ptr(mrb_value val);

struct RBasic*
mrb_basic_ptr(mrb_value val);

MRB_API struct RRange*
mrb_range_ptr(mrb_value val, mrb_value range);
```

#### 真偽値 -> `mrb_value`

```c
MRB_INLINE mrb_value
mrb_bool_value(mrb_bool boolean);
```

#### 値 (`mrb_value`) の取得

```c
MRB_INLINE mrb_value
mrb_true_value();

MRB_INLINE mrb_value
mrb_false_value();

MRB_INLINE mrb_value
mrb_nil_value();
```

#### 値のチェック

```c
int mrb_test_p(mrb_value o);      // 真
int mrb_nil_p(mrb_value o);       // nil
int mrb_true_p(mrb_value o);      // true
int mrb_false_p(mrb_value o);     // false
int mrb_undef_p(mrb_value o);     // undef
int mrb_fixnum_p(mrb_value o);    // Fixnum
int mrb_float_p(mrb_value o);     // Float
int mrb_symbol_p(mrb_value o);    // Symbol
int mrb_array_p(mrb_value o);     // Array
int mrb_string_p(mrb_value o);    // String
int mrb_hash_p(mrb_value o);      // Hash
int mrb_cptr_p(mrb_value o);      // CPtr
int mrb_exception_p(mrb_value o); // Exception
int MRB_FROZEN_P(mrb_value o);    // frozen
int mrb_immediate_p(mrb_value o); // 即値
```

## 参照
- 入門mruby 第10~13章
