# クラス (モジュール)
#### クラスの作成

```c
// クラスの作成
MRB_API struct RClass*
mrb_define_class(mrb_state *mrb, const char *name, struct RClass *super);

// ネストしたクラスの作成
MRB_API struct RClass*
mrb_define_class_under(mrb_state *mrb, struct RClass *outer, const char *name, struct RClass *super);

// モジュールの作成
MRB_API struct RClass*
mrb_define_module(mrb_state *mrb, const char *name);

// ネストしたモジュールの作成
MRB_API struct RClass*
mrb_define_module_under(mrb_state *mrb, struct RClass *outer, const char *name);
```

#### クラスへアクセス

```c
// クラス名を取得する
MRB_API const char*
mrb_class_name(mrb_state *mrb, struct RClass *klass);

// モジュール名を取得する
MRB_API const char*
mrb_module_name(mrb_state *mrb, struct RClass *klass);

// クラスを取得する
MRB_API struct RClass*
mrb_class_get(mrb_state *mrb, const char *name);

// モジュールを取得する
MRB_API struct RClass*
mrb_module_get(mrb_state *mrb, const char *name);
```

#### モジュールのインクルード

```c
MRB_API void
mrb_include_module(mrb_state *mrb, struct RClass *klass, struct RClass *module);
```

#### `MRB_SET_INSTANCE_TT` (マクロ)
- 当該クラス`c`のインスタンス一般についてのデータタイプを指定する
- 特定のクラスに所属するインスタンス全体についてのmrubyでの扱いを指定する

```c
MRB_SET_INSTANCE_TT(struct RClass *c, enum mrb_vtype tt)
```

#### クラス変数

```c
// クラス変数の値を取得する
MRB_API mrb_value
mrb_cv_get(mrb_state *mrb, mrb_value mod, mrb_sym sym);

MRB_API mrb_value
mrb_mod_cv_get(mrb_state *mrb, struct RClass *c, mrb_sym sym);

// クラス変数に値をセットする
MRB_API mrb_value
mrb_cv_set(mrb_state *mrb, mrb_value mod, mrb_sym sym, mrb_value val);

MRB_API mrb_value
mrb_mod_sv_get(mrb_state *mrb, struct RClass *c, mrb_sym sym, mrb_value val);

// クラス変数が定義されているかチェックする
MRB_API mrb_bool
mrb_cv_defined(mrb_state *mrb, mrb_value mod, mrb_sym sym);

MRB_API mrb_bool
mrb_mod_cv_defined(mrb_state *mrb, struct RClass *c, mrb_sym sym);
```

## 参照
- Webで使えるmrubyシステムプログラミング入門 Section022
- 入門mruby 第9章 / 第13章
