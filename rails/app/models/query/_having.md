# `having`
- レコードを持たないレコード一式を取得する

```ruby
class Writer < ApplicationRecord
  has_many :posts
end

Writer.left_joins(:posts).group('writers.id').having('count(posts.id) = 0')
```
