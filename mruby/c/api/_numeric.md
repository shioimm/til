# 数値
#### 数値 -> `mrb_value`

```c
MRB_INLINE mrb_value
mrb_int_value(mrb_state *mrb, mrb_int i);

MRB_INLINE mrb_value
mrb_fixnum_value(mrb_int i);

MRB_INLINE mrb_value
mrb_float_value(mrb_state *mrb, mrb_float f);
```

#### `mrb_value` -> 数値

```c
mrb_int
mrb_fixnum(mrb_value o);

mrb_float
mrb_float(mrb_value o);
```

#### Float (`mrb_value`) -> Fixnum (`mrb_value`)

```c
mrb_flo_to_fixnum(mrb_state *mrb, mrb_value val);
```

#### 数値 (`mrb_value`) -> String (`mrb_value`)

```c
mrb_value
mrb_fixnum_to_str(mrb_state *mrb, mrb_value x, mrb_int base);

mrb_value
mrb_float_to_str(mrb_state *mrb, mrb_value x, const char *fmt);
```

#### 四則演算

```c
mrb_value
mrb_num_plus(mrb_state *mrb, mrb_value x, mrb_value y);

mrb_value
mrb_num_minus(mrb_state *mrb, mrb_value x, mrb_value y);

mrb_value
mrb_num_mul(mrb_state *mrb, mrb_value x, mrb_value y);

mrb_float
mrb_div_float(mrb_value x, mrb_value y);
```

## 参照
- 入門mruby 第4章
