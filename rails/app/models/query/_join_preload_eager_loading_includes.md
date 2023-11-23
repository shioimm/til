# `join`, `preload`, `eager_loading`, `includes`
### `joins`
- 関連先テーブルを読み込まず (AR::Relationのオブジェクトを生成せず) INNER JOINでクエリをフィルタする

### `preload`
- 関連テーブルをまとめて取得し、キャッシュする
  - 指定した関連テーブル毎に別クエリを発行して関連テーブルのデータ配列を取得し、キャッシュする
    - 引数にn:n関連先を渡した場合、中間テーブルを介して取得しキャッシュする
    - preloadした関連先で絞り込みを行った場合は例外が発生する

#### 用途
- 無理してLEFT JOINするより素直に複数クエリを発行した方が良さそうな場合 e.g. 関連先が1:Nで紐づく場合 (`has_many`)
- 複数の関連先の事前読み込みを行う場合
  - IN句がDBの規定値よりも大きくなるとエラーが発生するケースがある

### `eager_load`
- 関連テーブルをまとめて取得し、キャッシュする
  - 指定した関連テーブルをLEFT OUTER JOINで結合して関連テーブルのデータ配列を取得し、キャッシュする
    - 引数として渡した関連先の要素で絞り込みを行うことが出来る

#### 用途
- 関連先の要素で絞り込みを行う場合
- LEFT JOINSでまとめて取得した方がお得な場合 e.g. 関連先が1:1 / N:1で紐づく場合 (`has_one`、`blongs_to`)

### `includes`
- デフォルトでは`preload`
- `ActiveRecord::Relation#eager_loading?`がtrueの場合`eager_load`
- 複数の関連先を指定した場合、必ずすべて`preload`もしくは`eager_load`される

#### `ActiveRecord::Relation#eager_loading?`
- `eager_load_values` が存在する -> true
- `includes_values` が存在する && `joined_includes_values` が存在する -> true
  - `joined_includes_values` = `includes` + `joins` されているアソシエーションの配列
- `includes_values` が存在する && `references_eager_loaded_tables?` がtrue -> true
  - `references_eager_loaded_tables?` = `includes(:association).references(:association)` しているアソシエーション

## 参照
- [Rails: JOINすべきかどうか、それが問題だ — #includesの振舞いを理解する（翻訳）](https://techracho.bpsinc.jp/hachi8833/2021_09_22/45650)
- [preload、`eager_load`、includesの挙動を理解して使い分ける](https://tech.stmn.co.jp/entry/2020/11/30/145159)
- [ActiveRecordのincludes, preload, `eager_load` の個人的な使い分け](https://moneyforward.com/engineers_blog/2019/04/02/activerecord-includes-preload-eagerload/)
