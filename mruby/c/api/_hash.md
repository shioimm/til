# ハッシュ
#### `mrb_value` (Hashオブジェクト) の作成

```c
// 空ハッシュを作成
MRB_API mrb_value
mrb_hash_new(mrb_state *mrb);

// 空ハッシュを作成 (初期化時にcapa分のメモリを確保)
MRB_API mrb_value
mrb_hash_new_capa(mrb_state *mrb, mrb_int capa);
```

#### Hashオブジェクトの要素へアクセス

```c
// ハッシュに値をセット
MRB_API void
mrb_hash_set(mrb_state *mrb, mrb_value hash, mrb_value key, mrb_value val);

// ハッシュの全キーを取得
MRB_API mrb_value
mrb_hash_keys(mrb_state *mrb, mrb_value hash);

// ハッシュの値を取得
MRB_API mrb_value
mrb_hash_get(mrb_state *mrb, mrb_value hash, mrb_value key);

// ハッシュ内のキーと値それぞれに対して関数を呼び出し
typedef int (mrb_hash_foreach_func)(mrb_state *mrb, mrb_value key, mrb_value val, void *data);

MRB_API void
mrb_hash_foreach(mrb_state *mrb, struct RHash *hash, mrb_hash_foreach_func *func, void *p);
```

## 参照
- 入門mruby 第8章
