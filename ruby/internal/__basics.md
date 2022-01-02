# MRI
- VALUE型: オブジェクトの実体である構造体を指す型
  - unsigned integer、プラットフォームによって異なる
  - 各種オブジェクト構造体へのポインタになる (`R...`マクロを利用してキャストされる)
  - 下位2~3bitが立っている場合 (および0) は即値として扱われる
- RVALUE構造体: gc.c (Rubyオブジェクトを表す)
- RBasic構造体: ruby/include/ruby/internal/core/rbasic.h

```c
struct
RUBY_ALIGNAS(SIZEOF_VALUE)
RBasic {
    VALUE flags;
    const VALUE klass;
    ...
};
```

- ID型: ruby/unclude/ruby/internal/value.h
  - Rubyレベルのデータ型として`::rb_cSymbol`が用意されている

```c
typedef uintptr_t ID;
```

- 特殊変数: rubyinclude/ruby/internal/`special_consts.h`
- RClass構造体: internal/class.h

```c
struct RClass {
    struct RBasic basic;
    VALUE super;
#if !USE_RVARGC
    struct rb_classext_struct *ptr;
#endif
#if SIZEOF_SERIAL_T == SIZEOF_VALUE
    /* Class serial is as wide as VALUE.  Place it here. */
    rb_serial_t class_serial;
#else
    /* Class serial does not fit into struct RClass. Place m_tbl instead. */
    struct rb_id_table *m_tbl;
#endif
};
```

- インスタンス変数への代入 (`rb_ivar_set`): variable.c

```c
VALUE
rb_ivar_set(VALUE obj, ID id, VALUE val)
{
    rb_check_frozen(obj);
    ivar_set(obj, id, val);
    return val;
}

static void
ivar_set(VALUE obj, ID id, VALUE val)
{
    RB_DEBUG_COUNTER_INC(ivar_set_base);

    switch (BUILTIN_TYPE(obj)) {
      case T_OBJECT:
        obj_ivar_set(obj, id, val);
        break;
      case T_CLASS:
      case T_MODULE:
        IVAR_ACCESSOR_SHOULD_BE_MAIN_RACTOR(id);
        rb_class_ivar_set(obj, id, val);
        break;
      default:
        generic_ivar_set(obj, id, val);
        break;
    }
}
```

- インスタンス変数の参照 (`rb_ivar_get`): variable.c

```c
VALUE
rb_ivar_get(VALUE obj, ID id)
{
    VALUE iv = rb_ivar_lookup(obj, id, Qnil);
    RB_DEBUG_COUNTER_INC(ivar_get_base);
    return iv;
}
```
