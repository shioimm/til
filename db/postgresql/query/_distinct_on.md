# `distinct on`
- 指定のカラムの値が重複している複数のレコードがあるとき、そのうちの一レコードを取得
- order byで並べ替えた最初のレコードを取得

```sql
select
    distinct on (user_id) *
from
    posts
order by
    user_id
    , created_at desc
```

```ruby
Post.select("distinct on (user_id) *").order("user_id, created_at desc")
```
