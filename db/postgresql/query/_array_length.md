# `array_length`

```sql
-- 空配列であるレコードを抽出

select
    *
from
    programmers
where
    array_length(favorite_languages, 1) is null;
```
