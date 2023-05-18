# バキューム処理 (VACUUM)
- テーブルを削除・更新した後に残る行ごとの不要領域を解放するための処理
  - VMをチェックし、対象ページを全走査
  - 不要行があれば対象テーブルのインデックスメンテナンスを行い不要行を削除
  - FSMを更新

#### VACUUM
- 不要行を削除した後、対象領域をOSに返さない (サイズは変わらない)
- 処理が早い
- 排他的ロックを取得しないため、テーブルへの読み書き操作と並行して実施が可能

#### VACUUM FULL
- 不要行を削除した後、対象領域をOSに返す
- 処理に時間がかかる
- VACUUMによるメンテナンスが想定通りに動作しなかった場合の対処策として使用される

#### VACUUM ANALYZE
- VACUUM後にANALYZEを実行する

## バキュームの状況を確認

```sql
-- 現在進行系で長時間実行されているクエリが存在していないかを確認

SELECT
  pid
  , query
FROM
  pg_stat_activity -- 状態や現在の問い合わせ等のプロセスの現在の活動状況に関連した情報
WHERE
  state = 'active';
```

```sql
-- 過去のバキューム状況をテーブル単位で確認

SELECT
  schemaname
  , relname
  , last_vacuum
  , last_autovacuum
  , vacuum_count
  , autovacuum_count
FROM
  pg_stat_all_tables; -- 特定のテーブルへのアクセスに関する統計情報
```

## 参照
- 内部構造から学ぶpostgresql 設計 運用計画の鉄則 15
