# JSON列の検索

```sql
select
  <テーブル名>.*
from
  <テーブル名>
where (<カラム名>->>'<キー名>' = '検索ワード')
```

```sql
select
  event_logs.*
from
  event_logs
where (json->>'type' = 'success')
```
