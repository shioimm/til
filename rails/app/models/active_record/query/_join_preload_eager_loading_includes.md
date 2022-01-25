# `join`, `preload`, `eager_loading`, `includes`
### `joins`
- 関連先テーブルを読み込まず (AR::Relationのオブジェクトを生成せず) INNER JOINでクエリをフィルタする

### `preload`
- 指定した関連テーブル毎に別クエリを作成、関連テーブルのデータ配列を取得し、キャッシュする
  - 引数にn:n関連先を渡した場合、中間テーブルを介して取得しキャッシュする
  - preloadした関連先で絞り込みを行った場合は例外が発生する

#### 用途
- `has_many`による関連先も含めてテーブルの事前読み込みを行う場合
- 複数の関連先の事前読み込みを行う場合
  - IN句がDBの規定値よりも大きくなるとエラーが発生するケースがある

### `eager_load`
- 指定した関連テーブルをLEFT OUTER JOINを用いて結合、
  1つのクエリで関連テーブルのデータ配列を取得し、キャッシュする
  - 引数として渡した関連先の要素で絞り込みを行うことが出来る

#### 用途
- 関連先の要素で絞り込みを行う場合
- `has_one`、`blongs_to`による関連先まで1クエリでデータを取得する場合
  - `eager_load`では常に結合処理を行うため、データ量が大きい場合はクエリが重くなる
  - クエリを分割して事前読み込みを行った方がレスポンスが早くなる場合は`preload`を利用する

### `includes`
- デフォルトでは`preload`と同じ挙動
- 他テーブルを結合しているか、関連先のテーブルで絞り込みを行っている場合は`eager_load`と同じ挙動

## 参照
- [Rails: JOINすべきかどうか、それが問題だ — #includesの振舞いを理解する（翻訳）](https://techracho.bpsinc.jp/hachi8833/2021_09_22/45650)
- [preload、`eager_load`、includesの挙動を理解して使い分ける](https://tech.stmn.co.jp/entry/2020/11/30/145159)
- [ActiveRecordのincludes, preload, `eager_load` の個人的な使い分け](https://moneyforward.com/engineers_blog/2019/04/02/activerecord-includes-preload-eagerload/)
