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

## 過去のバキューム状況を確認

```sql
select
  relname            -- テーブル名
  n_live_tup         -- 有効な行の推定値
  , n_dead_tup       -- 削除された行の推定値
  , last_vacuum      -- 最後にバキュームされた日時
  , last_autovacuum  -- 最後に自動バキュームされた
  , vacuum_count     -- 手作業でバキュームされた回数
  , autovacuum_count -- 自動バキュームされた回数
  , last_analyze     -- 最後に解析された日時
  , last_autoanalyze -- 最後に自動解析された日時
from
  pg_stat_all_tables; -- 特定のテーブルへのアクセスに関する統計情報
order by
  relname;
```

## 参照
- 内部構造から学ぶpostgresql 設計 運用計画の鉄則 15
