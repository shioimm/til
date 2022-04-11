# 配列

```c
#include <mruby/array.h>

struct RArray {
  MRB_OBJECT_HEADER;
  union {
    struct {
      mrb_ssize len;
      union {
        mrb_ssize capa;
        mrb_shared_array *shared;
      } aux;
      mrb_value *ptr;
    } heap;
#ifndef MRB_ARY_NO_EMBED
    mrb_value ary[MRB_ARY_EMBED_LEN_MAX];
#endif
  } as;
};
```

#### `mrb_value` (Arrayオブジェクト) の作成
```c
// 空配列を作成
MRB_API mrb_value
mrb_ary_new(mrb_state *mrb);

// 空配列を作成 (初期化時にcapa分のメモリを確保)
MRB_API mrb_value
mrb_ary_new_capa(mrb_state *mrb, mrb_int capa);

// 初期値をセットした配列を作成
MRB_API mrb_value
mrb_ary_new_from_values(mrb_state *mrb, mrb_int size, const mrb_value *vals);
```

#### Arrayオブジェクトの要素へアクセス

```c
// 配列に値をセット
MRB_API void
mrb_ary_set(mrb_state *mrb, mrb_value ary, mrb_int n, mrb_value val);

// 配列の値を取得
MRB_API mrb_value
mrb_ary_ref(mrb_state *mrb, mrb_value ary, mrb_int n);

// Arrayオブジェクト (mrb_value) の要素数を取得
mrb_int
RARRAY_LEN(mrb_value v);

// Arrayオブジェクトの要素数を取得
mrb_int
ARY_LEN(struct RArray *ary);

// Arrayオブジェクトに要素をpush
MRB_API void
mrb_ary_push(mrb_state *mrb, mrb_value ary, mrb_value val);

// Arrayオブジェクトから要素をpop
MRB_API mrb_value
mrb_ary_pop(mrb_state *mrb, mrb_value ary);

// Arrayオブジェクトから要素をshift
MRB_API mrb_value
mrb_ary_shift(mrb_state *mrb, mrb_value ary);
```

## 参照
- 入門mruby 第8章
