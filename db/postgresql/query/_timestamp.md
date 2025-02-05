# `timestamp without time zone`型カラム UTC -> JST

タイムゾーンをJSTとして値を表示する

```sql
select
    timezone('JST', sent_at::timestamptz)
from
    notifies
```
