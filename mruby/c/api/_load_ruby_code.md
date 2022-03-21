# コードの実行

```c
// 文字列として与えたRubyコードを実行
MRB_API mrb_value
mrb_load_string(mrb_state *mrb, const char *s);

MRB_API mrb_value
mrb_load_nstring(mrb_state *mrb, const char *s, int len);

// コンテキストの作成
MRB_API mrbc_context*
mrb_context_new(mrb_state *mrb);

// 文字列として与えたRubyコードをcxt環境で実行 (ローカル変数の値を引き継ぎたい場合など)
MRB_API mrb_value
mrb_load_string_cxt(mrb_state *mrb, const char *s, mrbc_context *cxt);

MRB_API mrb_value
mrb_load_nstring_cxt(mrb_state *mrb, const char *s, int len, mrbc_context *cxt);
```

## 参照
- 入門mruby 第9章
