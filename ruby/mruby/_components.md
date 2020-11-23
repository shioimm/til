# mrbgem-template
- 参照: Webで使えるmrubyシステムプログラミング入門 Section019

### `mrb_func_t`型
- Rubyスクリプトから使用できる関数ポインタ型
  - `mrb_state *mrb` / `mrb_value self`を引数にとる
  - `mrb_value`型を返す
- `mrb_define_method` / `mrb_define_class_method`の第四引数

### `mrb_state`構造体
- mrubyのVMの状態や各種変数などを格納した構造体
- `mrb_state`構造体の変数を引き回すことによってmrubyはプログラムを実行する

### `mrb_value`型
- mrubyのすべてのオブジェクトを表現するための型

### `RClass`構造体
- クラスやモジュールに固有の情報を格納する構造体
