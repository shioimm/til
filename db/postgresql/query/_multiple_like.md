# like句に複数のキーワードを渡したい

```sql
select
    count(*)
from
    posts
where
    body like any(array['Ruby%','Python%'])
```
