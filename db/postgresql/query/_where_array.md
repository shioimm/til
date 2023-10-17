# 配列型のカラムを配列でOR検索したい

```sql
select
  *
from
  book
where
  categories && ARRAY['novel', 'art', 'science']::varchar[]
;
```
