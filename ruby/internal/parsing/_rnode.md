# 構文木
- プログラムは構文解析後、構文木 (RNode構造体によって構成されるツリー構造) に変換される

## RNode構造体 (node.h)
- `flags`、3種類の共用体、`node_id`を持つ構造体
- 共用体の使い方はノードのタイプによって決まる

```c
typedef struct RNode {
  // VALUE flags               -> 構造体の型とノードのタイプを格納
  // union u1                  -> 共用体1に格納されるRNodeはツリーのヘッドを表す
  // union u2                  -> 共用体2に格納されるRNodeはツリーのボディを表す
  // union u3                  -> 共用体3に格納されるRNodeはツリーのテールを表す
  // rb_code_location_t nd_loc -> コードの位置を格納
  // int node_id
} NODE;
```

- RNode構造体はRubyオブジェクトであるためノードの生成と解放はRubyのGCによって管理される
- 新しいノードは`rb_node_newnode()`マクロ (parse.y) によって生成される

## 参照
- [第12章 構文木の構築](https://i.loveruby.net/ja/rhg/book/syntree.html)
