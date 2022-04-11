# 文字列
#### 文字列 -> `mrb_value`

```c
// 配列の長さがあらかじめわかっている場合
MRB_API mrb_value
mrb_str_new(mrb_state *mrb, const char *p, size_t len);

// 配列が'\0'で終端している場合
MRB_API mrb_value
mrb_str_new_cstr(mrb_state *mrb, const char *p);

// C文字列リテラルから変換する場合
MRB_API mrb_value
mrb_str_new_lit(mrb_state *mrb, const char *p)
```

#### `mrb_value` -> 文字列

```c
MRB_API char*
mrb_str_to_cstr(mrb_state *mrb, mrb_value str);

MRB_API const char*
mrb_string_cstr(mrb_state *mrb, mrb_value str);

// 文字列のポインタを取得
char *RSTRING_PTR(mrb_value str);

// 文字列の長さを取得
mrb_int RSTRING_LEN(mrb_value str);
```

#### `mrb_value` + 文字列

```c
// 配列の長さがあらかじめわかっている場合
MRB_API mrb_value
mrb_str_cat(mrb_state *mrb, mrb_value str, const char *ptr, size_t len);

// 配列が'\0'で終端している場合
MRB_API mrb_value
mrb_str_cat_cstr(mrb_state *mrb, mrb_value str, const char *ptr);

// C文字列リテラルから変換する場合
MRB_API mrb_value
mrb_str_cat_lit(mrb_state *mrb, mrb_value str, const char *lit)
```

#### `mrb_value` + `mrb_value`

```c
MRB_API mrb_value
mrb_str_cat_str(mrb_state *mrb, mrb_value str, mrb_value str);
```

#### 文字列 -> シンボル (`mrb_sym`)
- `mrb_sym` = 32ビット符号なし整数(`uint32_t`)

```c
// 配列の長さがあらかじめわかっている場合
MRB_API mrb_sym
mrb_intern_cstr(mrb_state *mrb, const char* str);

// 配列が'\0'で終端している場合
MRB_API mrb_sym
mrb_intern(mrb_state *mrb, const char* name, size_t len);

// C文字列リテラルから変換する場合
MRB_API mrb_sym
mrb_intern_lit(mrb_state *mrb, const char* name);
```

#### シンボル (`mrb_sym`) -> Symbolオブジェクト

```c
MRB_INLINE mrb_value
mrb_symbol_value(mrb_sym i);
```

#### 文字列 (`mrb_value`) -> シンボル (`mrb_sym`)

```c
MRB_API mrb_sym
mrb_obj_to_sym(mrb_state *mrb, mrb_value name);
```

#### シンボル (`mrb_sym`) -> 文字列

```c
MRB_API const char*
mrb_sym2name(mrb_state *mrb, mrb_sym mid);
```

## 参照
- Webで使えるmrubyシステムプログラミング入門 Section019
- 入門mruby 第5章
