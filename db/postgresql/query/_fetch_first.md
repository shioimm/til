# fetch first
最初のN行のみ取得

```sql
select
    *
from
    books
order by
    published_at desc
fetch first
    10 rows only
```
