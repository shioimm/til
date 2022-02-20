# データ型
#### `mrb_state`構造体
- mruby VMの状態や各種変数などを格納した構造体
- `mrb_state`構造体の変数を引き回すことによってmrubyはプログラムを実行する

#### `mrb_value`共用体
- mrubyのすべてのオブジェクトを表現するための型

```c
union mrb_value_union {
  void    *p; // RData構造体へのポインタ
  mrb_int  i;
  mrb_sym  sym;
};

typedef struct mrb_value {
  union mrb_value_union value;
  enum mrb_type         tt;
} mrb_value;
```

#### `mrb_data_type`構造体
- インスタンスのデータを解放する方法を格納する構造体

```c
#include <mruby/data.h>

typedef struct mrb_data_type {
  const char  *struct_name;
  void       (*dfree)(mrb_state *mrb, *void);
} mrb_data_type;

```

#### `mrb_func_t`型
- Rubyスクリプトから使用できる関数ポインタ型
  - `mrb_state *mrb` / `mrb_value self`を引数にとる
  - `mrb_value`型を返す
- メソッド定義のために使用する
  - `mrb_define_method` / `mrb_define_class_method`の第四引数

#### `RData`構造体
- `mrb_value`共用体の実際のデータを管理する構造体

```c
struct RData {
  void          *data; // インスタンスが持つデータ
  mrb_data_type *type; // インスタンスが持つデータを解放するためのタイプ
}
```

- `DATA_PTR(self)` - インスタンスが持つデータへのアクセス
- `DATA_TYPE(self)` - インスタンスが持つデータを解放する方法へのアクセス

#### `RClass`構造体
- クラスやモジュールに固有の情報を格納する構造体

## 参照
- Webで使えるmrubyシステムプログラミング入門 Section019
