# `exists`

```sql
-- "Ruby"がタイトルに含まれた本を一冊でも出版している出版社を取得する

select
    name
from
    publishers
where -- 条件を満たす行が一行でもあればその行 (publishersレコード) を返す
    exists (
        select
            1
        from
            books
        where
            books.publisher_id = publishers.id
        and
            books.title like '%Ruby%'
    )
;
```

```sql
-- "Ruby"がタイトルに含まれた本を一冊も出版していない出版社を取得する

select
    name
from
    publishers
where
    not exists (
        select
            1
        from
            books
        where
            books.publisher_id = publishers.id
        and
            books.title like '%Ruby%'
    )
;
```
