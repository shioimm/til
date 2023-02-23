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

| 分類     | 演算子           | 意味                                                                     |
| -        | -                | -                                                                        |
| スキャン | Seq Scan         | テーブル全体を順番にスキャンした後テーブルにアクセスしレコードを取得     |
| スキャン | Index Scan       | インデックス全体を順番にスキャンした後テーブルにアクセスしレコードを取得 |
| スキャン | Index Only Scan  | インデックス全体を順番にスキャンした後インデックスのカラムの値を取得     |
| スキャン | Bitmap Scan      | インデックスからビットマップを作成・ソートし、該当位置のレコードを取得   |
| 結合     | Nested Loop      | 外側のテーブルの一行ごとに内側のテーブルを全て評価                       |
| 結合     | Merge Join       | 二つのテーブルを結合キーでソートし、順番に付き合わせて評価               |
| 結合     | Hash Join        | 内側テーブルの結合キーで作成したハッシュと外側テーブルの結合キーを評価   |
| 加工     | Group            | GROUP BY                                                                 |
| 加工     | limit            | LIMIT / OFFSET                                                           |
| 加工     | Unique           | UNIQUE                                                                   |
| 加工     | Sort             | レコードセットをソート                                                   |
| 加工     | Aggregate        | 集約関数の実行                                                           |
| 加工     | Group Aggregate  | 集約関数にGROUP BYを使用する                                             |
| その他   | Filter           | レコードセットから条件を満たすレコードを選択                             |

#### 実行コスト
- cost=n..m
  - 操作の実行に要する作業量
  - n - 始動コスト (検索結果の一行目を返却できるようになるまでにかかるコスト)
  - m - 総コスト (nを含めて全ての行を返却できるようになるまでにかかるコスト)
- rows=n
  - 返却される行数
- width=n
  - 返却される行の平均の長さ (バイト単位)

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

#### キャッシュヒット数も出力
- 各処理に対して `Buffers: shared hit` としてバッファキャッシュヒット数を表示する
  - 数値が大きいほどキャッシュが効いている

```sql
# explain (analyze, buffers) select * from users order by created_at limit 10;
```

#### 追加情報の出力
- 計画ツリー、スキーマ修飾テーブル、関数名内の各ノードに対して出力列リストを含める

```sql
# explain (verbose) select * from users order by created_at limit 10;
```

#### 出力フォーマットの整形

```sql
# explain (analyze, format yaml) select * from users order by created_at limit 10;

# explain (analyze, format json) select * from users order by created_at limit 10;
```

## 参照・引用
- [【PostgreSQL】初心者でも読める実行計画の基礎知識](https://tech-blog.rakus.co.jp/entry/20200612/postgreSQL)
- [[Rails] RubyistのためのPostgreSQL EXPLAINガイド（翻訳）](https://techracho.bpsinc.jp/hachi8833/2017_03_29/37986)
- [Rails: データベースのパフォーマンスを損なう3つの書き方（翻訳）](https://techracho.bpsinc.jp/hachi8833/2021_06_24/50793)
