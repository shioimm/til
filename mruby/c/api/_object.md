# オブジェクト
#### インスタンスの作成

```c
MRB_API mrb_value
mrb_obj_new(mrb_state *mrb, struct RClass *c, mrb_int argc, const mrb_value *args);
```

#### インスタンス変数へのアクセス
```c
// インスタンス変数の値を取得する
MRB_API mrb_value
mrb_iv_get(mrb_state *mrb, mrb_value self, mrb_sym sym);

MRB_API mrb_value
mrb_obj_iv_get(mrb_state *mrb, struct RObject *obj, mrb_sym sym);

// インスタンス変数に値をセットする
MRB_API void
mrb_iv_set(mrb_state *mrb, mrb_value self, mrb_sym sym, mrb_value v);

MRB_API mrb_value
mrb_obj_iv_set(mrb_state *mrb, struct RObject *obj, mrb_sym sym, mrb_value v);

// インスタンス変数の定義を確認する
MRB_API mrb_bool
mrb_iv_defined(mrb_state *mrb, mrb_value obj, mrb_sym sym);

MRB_API mrb_bool
mrb_obj_iv_defined(mrb_state *mrb, struct RObject *obj, mrb_sym sym);

// インスタンス変数を削除する
MRB_API void
mrb_iv_remove(mrb_state *mrb, mrb_value obj, mrb_sym sym);
```

#### インスタンスの操作

```c
// オブジェクトのコピー
MRB_API mrb_value
mrb_obj_dup(mrb_state *mrb, mrb_value obj);

// オブジェクトのコピー (オブジェクト単位で定義された特異メソッドやfreeze情報もコピー)
MRB_API mrb_value
mrb_obj_clone(mrb_state *mrb, mrb_value obj);

// オブジェクトからクラス名を取得
MRB_API const char*
mrb_obj_classname(mrb_state *mrb, mrb_value obj);

// オブジェクトからクラス (RClass構造体) を取得
MRB_API struct RClass*
mrb_obj_class(mrb_state *mrb, mrb_value obj);

// オブジェクトが特定のクラスのインスタンスであることをチェック
MRB_API mrb_bool
mrb_obj_is_kind_of(mrb_state *mrb, mrb_value obj, struct RClass *c);

// オブジェクトへinspectメソッドを呼ぶ
MRB_API mrb_value
mrb_inspect(mrb_state *mrb, mrb_value obj);

// オブジェクトへto_sメソッドを呼ぶ
MRB_API mrb_value
mrb_obj_as_string(mrb_state *mrb, mrb_value obj);

// オブジェクト同士を比較
MRB_API mrb_bool
mrb_obj_equal(mrb_state *mrb, mrb_value obj1, mrb_value obj2);

MRB_API mrb_bool
mrb_obj_eq(mrb_state *mrb, mrb_value obj1, mrb_value obj2);

MRB_API mrb_bool
mrb_equal(mrb_state *mrb, mrb_value obj1, mrb_value obj2);

MRB_API mrb_bool
mrb_eq(mrb_state *mrb, mrb_value obj1, mrb_value obj2);
```

## 参照
- Webで使えるmrubyシステムプログラミング入門 Section022
- 入門mruby 第10~13章
