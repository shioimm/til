# 例外
#### 例外の送出
```c
MRB_API mrb_noreturn void
mrb_raise(mrb_state *mrb, struct RClass *c, const char *msg);

// メッセージテンプレートに出力
MRB_API mrb_noreturn void
mrb_raisef(mrb_state *mrb, struct RClass *c, const char *fmt, );

// NameErrorを例外として上げる場合
MRB_API mrb_noreturn void
mrb_name_error(mrb_state *mrb, mrb_sym id, const char *fmt, ...);

// システムに関わるエラーを例外として上げる場合
MRB_API void
mrb_sys_fail(mrb_state *mrb, const char *msg);
```

#### エラー表示

```c
MRB_API void
mrb_print_error(mrb_state *mrb);
```

#### 例外の捕捉

```c
// rescue
MRB_API mrb_value
mrb_rescue_exceptions(
  mrb_state      *mrb,
  mrb_func_t      body,
  mrb_value       b_data,
  mrb_func_t      rescue,
  mrb_value       r_data,
  mrb_int_len     len,
  struct RClass **classes
);

// rescue (StandardErrorのみ対応)
MRB_API mrb_value
mrb_rescue(
  mrb_state  *mrb,
  mrb_func_t  body,
  mrb_value   b_data,
  mrb_func_t  rescue,
  mrb_value   r_data
);

// ensure
MRB_API mrb_value
mrb_ensure(
  mrb_state  *mrb,
  mrb_func_t  body,
  mrb_value   b_data,
  mrb_func_t  ensure,
  mrb_value   e_data
);

// 例外捕捉時に大域脱出させず、例外オブジェクトを返す場合
MRB_API mrb_value
mrb_protect(
  mrb_state  *mrb,
  mrb_func_t  body,
  mrb_value   data,
  mrb_bool   *state
);
```

## 参照
- Webで使えるmrubyシステムプログラミング入門 Section019
- 入門mruby 第14章
