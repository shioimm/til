# `mrb_value`

```c
union mrb_value_union {
#ifndef MRB_NO_FLOAT
  mrb_float f;
#endif
  void *p; // RVALUE構造体へのポインタ
  mrb_int i;
  mrb_sym sym;
};

typedef struct mrb_value {
  union mrb_value_union value;
  enum  mrb_type        tt;
} mrb_value;
```

#### RVALUE構造体 (e.g. `RData`構造体)
- 実際のデータを管理するための構造体
- mrubyレベルでオブジェクトのデータを管理する場合は`mrb_value`経由で使用される
- Cレベルでデータを管理したい場合は`mrb_value`を経由せず直接`RData構造体`として使用される

```c
#include <mruby/data.h>

struct RData {
  MRB_OBJECT_HEADER;
  struct iv_tbl        *iv;
  const  mrb_data_type *type; // データを解放するためのタイプ
  void                 *data; // 実際のデータへのポインタ
}
```

- `DATA_PTR(mrb_value self)`
  - `mrb_value`から`RData`構造体`data`メンバへのアクセス
- `DATA_TYPE(mrb_value self)`
  - `mrb_value`から`RData`構造体`type`メンバへのアクセス
- `MRB_SET_INSTANCE_TT(struct RClass *c, enum mrb_vtype tt)`
  - Cのデータをバックエンドに持ち、特定のクラスに所属するインスタンスについてデータタイプを指定する

```c
// インスタンスにCレベルのデータを持たせる

// インスタンスに紐づけるCレベルの構造体
typedef struct {
  int n;
} mrb_prog_data;

// インスタンスに紐づけるCレベルの構造体の解放方法
static const struct mrb_data_type mrb_prog_data_type = {
  "mrb_prog_data", // 解放する対象の構造体型名
  mrb_free,        // struct mrb_prog_data型のデータをどのように解放するか
};

mrb_value mrb_func(mrb_state *mrb, mrb_value self)
{
  mrb_prog_data *data = (mrb_prog_data*)DATA_PTR(self);
  data->n = 1;

  // RData構造体のdataメンバにCレベルのデータmrb_prog_data *dataを紐づける
  DATA_PTR(self) = data;

  // RData構造体のtypeメンバにCレベルのデータmrb_prog_data *dataの解放方法を紐づける
  DATA_TYPE(self) = &mrb_prog_data_type;

  return self:
}

int main(void)
{
  mrb_state *mrb = mrb_open();

  mrb_value self = mrb_load_string(mrb, "Object.new");

  struct RClass obj_class = mrb_class_get(mrb, "Object");
  MRB_SET_INSTANCE_TT(obj_class, MRB_TT_OBJECT);

  mrb_func(mrb, self);

  mrb_close(mrb);

  return 0;
}
```

#### `mrb_data_type`構造体

```c
#include <mruby/data.h>

typedef struct mrb_data_type {
  const char  *struct_name;                   // データタイプ名
  void       (*dfree)(mrb_state *mrb, *void); // RData構造体のdataメンバを解放する関数
} mrb_data_type;
```
