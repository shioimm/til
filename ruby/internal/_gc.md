# GC
#### 特徴
- 基本アルゴリズムはマークアンドスイープ
- 保守的
- 世代別にGCを行う
- インクリメンタルにGCを行う

## 実行タイミング
- 新しいオブジェクトを生成しようとしたが、空いているスロットがなかった
- `malloc()`によるメモリ確保が一定量を超えた
- `GC.start`や`GC.stress`による強制起動

## 動作
- R~構造体として割り当てられる領域が枯渇した際、
  `gc_start()`関数が呼ばれ、マークフェーズおよびスイープフェーズを開始する

#### スロット
- R~構造体のメモリ領域

#### ページ
- スロットをまとめた領域
- メモリの確保や解放を行う単位
- `heap_page_body`構造体 / `heap_page`構造体の組みによって表現される
- すべて空きスロットになったページに対してはメモリの解放が行われる

```c
// 16KB固定長
// 400スロットのR~構造体 (400オブジェクト) を格納できる

struct heap_page_body {
  struct heap_page_header header; // heap_pageへのアドレス
  /* char gap[];      */
  /* RVALUE values[]; */
};
```

```c
// ページの管理情報
// heap_page同士は双方向連結リストになっている

struct heap_page {
  // ページにおける先頭スロットのアドレス
  // 空きスロットリストへのポインタ
  // マークビットなどのビットマップ etc
};
```

#### ヒープ領域
- ページの集合・GCの管理領域

## シンボルGC
- VALUEの下位8ビットが0x0cであれば静的シンボル
- VALUEの下位8ビットが0x0cでなければ動的シンボル (VALUEはRSymbol構造体へのポインタ)

#### シンボルの生成時
- 同名のIDがない場合 -> 動的シンボルとして生成
- 同名のIDがある場合 -> 静的シンボルとして生成

#### IDの生成時
- 同名の動的シンボルがない場合 -> 生成したIDはシンボルへの変換時に静的シンボルを返す
- 同名の動的シンボルがある場合 -> 生成したIDはシンボルへの変換時に当該動的シンボルを返す

#### 不要時
- IDの不要時 -> IDは削除されない
- 静的シンボルの不要時 -> 静的シンボルはGCされない
- 動的シンボルの不要時 -> 動的シンボルはGCされる

## 参照
- Rubyのウラガワ ── Rubyインタプリタに学ぶデータ構造とアルゴリズム
  - RubyのGCの基礎 GCのデータ構造とアルゴリズム
  - インタプリタでの名前管理とシンボルGC
