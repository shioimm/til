# カラムAがnullのものを優先しつつカラムBの降順にソート

```sql
select
    *
from
    posts
order by
    already_read_at is not null nulls first,
    written_at desc
;
```

```ruby
Post.order(Arel.sql("already_read_at is not null nulls first"), written_at: :desc)
```
