# データ型
#### `RData`構造体
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

- `DATA_PTR(self)` - データへのアクセス
- `DATA_TYPE(self)` - データを解放するタイプへのアクセス

#### `mrb_data_type`構造体
- `RData`構造体の保持するデータを解放する方法を格納する構造体

```c
#include <mruby/data.h>

typedef struct mrb_data_type {
  const char  *struct_name; // データを解放するためのタイプの名前
  void       (*dfree)(mrb_state *mrb, *void); // RData構造体のvoid *dataを解放するための関数
} mrb_data_type;

```

#### `mrb_func_t`型
- Rubyスクリプトから使用できる関数ポインタ型
- メソッド定義のために使用する
  - `mrb_define_method` / `mrb_define_class_method`の第四引数

```c
#include <mruby.h>

typedef mrb_value (*mrb_func_t)(struct mrb_state *mrb, mrb_value self);
```

#### `RClass`構造体
- クラスやモジュールに固有の情報を格納する構造体

```c
#include <mruby/class.h>

struct RClass {
  MRB_OBJECT_HEADER;
  struct iv_tbl *iv;
  struct mt_tbl *mt;
  struct RClass *super;
};
```

## 参照
- Webで使えるmrubyシステムプログラミング入門 Section019
