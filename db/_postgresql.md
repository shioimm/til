# PostgreSQL
## 実行計画
- ツリー構造のうち、一番下のノードから順番にルートに向かって遡って実行される
- 兄弟ノードがある場合は先に記述されている方から実行される

#### 演算子
- Seq Scan - シーケンシャルスキャン
- Index Scan - インデックススキャン
- Hash Join - テーブルの結合
- Sort - ソート

#### 実行コスト
- cost=n..m
  - 処理の重さ
  - n - 初期コスト(検索結果の一行目を返すまでにかかるコスト)
  - m - 総コスト(初期コストを含めた処理完了までにかかるコスト)
- rows=n
  - 処理が行われる対象のレコード行数
- width=n
  - 返却される行あたりの長さ

## バージョン管理ツール
- [Postgres.app](https://postgresapp.com/)のAdditional Releasesが便利
  - バージョンが揃っているものを選ぶと重い
  - [Postico](https://eggerapps.at/postico/)とシームレスに連携している

## 参照
- [【PostgreSQL】初心者でも読める実行計画の基礎知識](https://tech-blog.rakus.co.jp/entry/20200612/postgreSQL)
