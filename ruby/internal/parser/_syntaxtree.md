# 構文木
- プログラムは構文解析後、構文木 (RNode構造体によって構成されるツリー構造) に変換される

## RNode構造体 (node.h)
- 構文木を構築するノードを表現する構造体
- Rubyオブジェクトであり、ノードの生成と解放はRubyのGCによって管理される

```c
typedef struct RNode {
  // VALUE flags               -> 構造体の型とノードのタイプを格納
  // union u1, u2, u3          -> ノードのタイプによって必要な情報を格納する
  // rb_code_location_t nd_loc -> コードの位置を格納
  // int node_id
} NODE;
```

- `rb_node_newnode()` - 新しいノードの生成
- `nd_set_type()`     - `flags`にノードタイプをセット
- `nd_type`           - `flags`からノードタイプを取得

## 参照
- [第12章 構文木の構築](https://i.loveruby.net/ja/rhg/book/syntree.html)
