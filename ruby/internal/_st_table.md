# `st_table`
- ハッシュテーブル (配列)
- キーは配列のインデックスとなる数値
  - ID (任意の文字列と一対一で対応する数値: シンボル) 、VALUE、`char*`をハッシュ関数に与え算出した値
  - ハッシュ値の衝突が発生した場合、開番地法による衝突回避を行う
- RHashは`st_table`のラッパー構造体

```c
// include/ruby/st.h

struct st_table {
  unsigned char              entry_power, bin_power, size_ind;
  unsigned int               rebuilds_num;
  const struct st_hash_type *type;
  st_index_t                 num_entries;
  st_index_t                *bins;
  st_index_t                 entries_start, entries_bound;
  st_table_entry            *entries;
};

// binsの各要素にはentriesのインデックスを設定し、binsには開番地法でテーブルアクセスする
```

```c
// st.c

struct st_table_entry {
  st_hash_t hash;   // ハッシュ値
  st_data_t key;    // キー
  st_data_t record; // 値
};

```
## 参照
- Rubyのウラガワ ── Rubyインタプリタに学ぶデータ構造とアルゴリズム
  - 連鎖法から開番地法への進化の歴史
