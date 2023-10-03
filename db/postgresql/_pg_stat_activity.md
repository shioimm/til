# `pg_stat_activity`
- 状態や現在の問い合わせ等のプロセスの現在の活動状況に関連した情報
- https://www.postgresql.jp/document/11/html/monitoring-stats.html#PG-STAT-ACTIVITY-VIEW

#### 現在進行系で長時間実行されているクエリが存在していないかを確認

```sql
select
  pid
  , xact_start
  , query
  , query_start
  , state
  , state_change
from
  pg_stat_activity
where
  state = 'active';
```
