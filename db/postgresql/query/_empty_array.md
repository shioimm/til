# 空配列のレコードを抽出

```sql
select
    *
from
    programmers
where
    array_length(languages, 1) is null;
```
