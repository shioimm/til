# メモリ管理

```cc
// Cのデータをバックエンドに持ち、特定のクラスに所属するインスタンスについてデータタイプを指定する

MRB_SET_INSTANCE_TT(struct RClass *c, enum mrb_vtype tt)
```

#### メモリの確保 (Cレベル)

```c
// malloc
MRB_API void*
mrb_malloc(mrb_state *mrb, size_t len);

// malloc (メモリの確保に失敗した場合NULLを返す)
MRB_API void*
mrb_malloc_simple(mrb_state *mrb, size_t len);

// calloc
MRB_API void*
mrb_calloc(mrb_state *mrb, size_t nelem, size_t len);

// realloc
MRB_API void*
mrb_realloc(mrb_state *mrb, void *p, size_t len);

// realloc (メモリの確保に失敗した場合NULLを返す)
MRB_API void*
mrb_realloc_simple(mrb_state *mrb, void *p, size_t len);
```

#### メモリの解放 (Cレベル)

```c

MRB_API void*
mrb_free(mrb_state *mrb, void *p);
```

#### メモリの確保 (オブジェクトレベル)

```c
MRB_API struct RBasic*
mrb_obj_alloc(mrb_state *mrb, enum mrb_vtype ttype, struct RClass *cls);
```

- `enum mrb_vtype`
  - 既存のクラスのオブジェクトの場合はその`mrb_vtype`を指定する
  - そうでない場合は`MRB_TT_DATA`で取り出した`mrb_vtype`を指定する

#### GCの操作

```c
MRB_API void
mrb_incremental_gc(mrb_state *mrb);

MRB_API void
mrb_full_gc(mrb_state *mrb);
```

#### GC arenaの操作

```c
// arenaのメモリ拡張を止める (arenaのスタック位置を保存)
MRB_API int
mrb_gc_arena_save(mrb_state *mrb);

// arenaのメモリ拡張を再開する (arenaのスタック位置を復元)
MRB_API void
mrb_gc_arena_restore(mrb_state *mrb, int idx)
```

## 参照
- 入門mruby
