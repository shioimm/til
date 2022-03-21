# メソッド呼び出し

```c
// メソッド名をCの文字列として指定する場合
MRB_API mrb_value
mrb_funcall(
  mrb_state *mrb, mrb_value self, const char *name, mrb_int argc, ...
);

// メソッド名をmrb_sym, 引数をmrb_valueの配列で渡す場合
MRB_API mrb_value
mrb_funcall_argv(
  mrb_state *mrb, mrb_value self, mrb_sym mid, mrb_int argc, const mrb_value *argv
);

// メソッド名をmrb_sym, 引数をmrb_valueの配列で渡し、引数にブロックを追加する場合
MRB_API mrb_value
mrb_funcall_with_block(
  mrb_state *mrb, mrb_value self, mrb_sym mid, mrb_int argc, const mrb_value *argv, mrb_value blk
);
```

#### ブロック

```c
// Rubyで書かれたブロックを実行
MRB_API void
mrb_yield(mrb_state *mrb, mrb_value blk, mrb_value argvs);
```

## 参照
- 入門mruby 第9章
