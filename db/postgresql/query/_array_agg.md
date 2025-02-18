# グループごとにカラムの値をまとめる

```sql
-- 著者ごとに著書のタイトルをまとめて取得
select
    author_id
    , array_agg(title) as book_titles
from
    books
group by
    author_id;
```
