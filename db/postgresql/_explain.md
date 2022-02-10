# 実行計画
```
# explain select * from users order by created_at limit 10;

                               QUERY PLAN
-------------------------------------------------------------------------
 Limit  (cost=892.98..893.01 rows=10 width=812)
   ->  Sort  (cost=892.98..919.16 rows=104 width=812)
         Sort Key: created_at
         ->  Seq Scan on users  (cost=0.00..666.71 rows=104 width=812)
(4 rows)
```

- ツリー構造のうち、一番下のノードから順番にルートに向かって遡って実行される
- 子ノードの出力は親ノードにパイプで接続される
- 兄弟ノードがある場合は先に記述されている方から実行される

#### 実行計画の構成要素
- ノードリスト (node list): クエリ実行に必要な操作 (action) の順序を示す
- パフォーマンス予測 (performance estimate) : リストの各項目の実行にかかるコストを示す

#### 演算子

| 分類             | 演算子           | 意味                                               |
| -                | -                | -                                                  |
| テーブルスキャン | Seq Scan         | 全件スキャン                                       |
| テーブルスキャン | Index Scan       | インデックスを使用してスキャン                     |
| テーブルスキャン | BitmapScan       | ビットマップを使用してスキャン                     |
| テーブルスキャン | Index Only Scan  | インデックスに含まれるカラムのみで完結するスキャン |
| テーブル結合     | Nested Loop      | 行ごとに条件の合うレコードを探して結合             |
| テーブル結合     | Merge Join       | 両テーブルを結合キーでソートして結合               |
| テーブル結合     | Hash Join        | 両テーブルの結合キーからハッシュ値を作って結合     |
| 検索結果への操作 | Group            | GROUP BY                                           |
| 検索結果への操作 | limit            | LIMIT / OFFSET                                     |
| 検索結果への操作 | Unique           | UNIQUE                                             |
| 検索結果への操作 | Sort             | レコードセットをソート                             |
| 検索結果への操作 | Aggregate        | 集約関数の実行                                     |
| 検索結果への操作 | Group Aggregate  | 集約関数にGROUP BYを使用する                       |
| その他           | Filter           | レコードセットから条件を満たすレコードを選択       |

#### 実行コスト
- cost=n..m
  - 操作の実行に要する作業量
  - n - 初期コスト (検索結果の一行目を返すまでにかかるコスト)
  - m - 総コスト (初期コストを含めた処理完了までにかかるコスト)
- rows=n
  - 処理が行われる対象のレコード行数
- width=n
  - 各行のサイズ予測値 (バイト単位)

## 実際の実行時間を取得する
- 実際にクエリを実行し、EXPLAINで計画されたノードごとの実際の行数と実行時間を取得する

```
# explain analyze select * from users order by created_at limit 10;
                                                       QUERY PLAN
------------------------------------------------------------------------------------------------------------------------
 Limit  (cost=892.98..893.01 rows=10 width=812) (actual time=22.443..22.446 rows=10 loops=1)
   ->  Sort  (cost=892.98..919.16 rows=10471 width=812) (actual time=22.441..22.443 rows=10 loops=1)
         Sort Key: created_at
         Sort Method: top-N heapsort  Memory: 31kB
         ->  Seq Scan on users  (cost=0.00..666.71 rows=10471 width=812) (actual time=0.203..15.221 rows=10472 loops=1)
 Total runtime: 22.519 ms
(6 rows)
```

#### 実行コスト
- actual time=n..m
  - 操作の実行に要した時間 (ms)
- rows
  - 実際に処理した行数
- loops
  - 操作のループが発生した回数

## 出力フォーマットの整形
```
# explain (analyze, format yaml) select * from users order by created_at limit 10;
```

## 参照・引用
- [【PostgreSQL】初心者でも読める実行計画の基礎知識](https://tech-blog.rakus.co.jp/entry/20200612/postgreSQL)
- [[Rails] RubyistのためのPostgreSQL EXPLAINガイド（翻訳）](https://techracho.bpsinc.jp/hachi8833/2017_03_29/37986)
- [Rails: データベースのパフォーマンスを損なう3つの書き方（翻訳）](https://techracho.bpsinc.jp/hachi8833/2021_06_24/50793)
