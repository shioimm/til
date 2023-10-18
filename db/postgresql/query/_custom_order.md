# 任意の順にorderしたい

```sql
select
  *
from
  books
order by
  case category
  when 'novel'   then 1
  when 'art'     then 2
  when 'science' then 3
  end
;
```
