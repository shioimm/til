# `join`, `preload`, `eager_loading`, `includes`
#### `joins`
- 関連先テーブルを読み込まず (AR::Relationのオブジェクトを生成せず) INNER JOINでクエリをフィルタする

#### `preload`
- 指定した関連テーブルを別のクエリで取得しキャッシュする

#### `eager_load`
- 指定した関連テーブルをLEFT JOINを用いて1つのクエリで取得しキャッシュする

#### `includes`
- デフォルトで`preloading`戦略
- `references`と組み合わせると`eager_loading`戦略

## 参照
- [Rails: JOINすべきかどうか、それが問題だ — #includesの振舞いを理解する（翻訳）](https://techracho.bpsinc.jp/hachi8833/2021_09_22/45650)
