# 定数
#### 定数の定義

```c
// モジュールmodの下にnameの名前で定数を定義する
MRB_API void
mrb_define_const(mrb_state *mrb, struct RClass *mod, const char *name, mrb_value v);
```

#### 定数の操作

```c
// 定数の値を取得する
MRB_API mrb_value
mrb_const_get(mrb_state *mrb, mrb_value mod, mrb_sym sym);

// 定数に値をセットする
MRB_API void
mrb_const_set(mrb_state *mrb, mrb_value mod, mrb_sym sym, mrb_value v);

// 定数の定義を確認する
MRB_API mrb_bool
mrb_const_defined(mrb_state *mrb, mrb_value mod, mrb_sym id);

// 定数を削除する
MRB_API void
mrb_const_remove(mrb_state *mrb, mrb_value mod, mrb_sym sym);
```

## 参照
- 入門mruby 第13章
