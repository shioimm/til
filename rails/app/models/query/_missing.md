# `missing`
- 関連先レコードを持たないレコード一式を取得する

```ruby
class Writer < ApplicationRecord
  has_many :posts
end

# Postレコードを持たないWriterレコードを取得する
Writer.where.missing(:posts)
Writer.left_outer_joins(:posts).where(posts: { id: nil })

# writer_idの存在しないPostレコードを取得する
Post.where.missing(:writer)
Post.left_joins(:writer).where(writers: { id: nil })
```

- 逆 (関連先レコードを持つレコード一式を取得する) は`associated`
