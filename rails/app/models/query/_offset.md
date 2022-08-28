# offset

```ruby
[1] pry(main)> puts Book.offset(1).to_sql
SELECT "books"."id", "books"."title", "books"."author", "books"."created_at", "books"."updated_at", "books"."deleted_at", FROM "books" WHERE "books"."deleted_at" IS NULL OFFSET 1
```

## 参照
- [offset(value)](https://api.rubyonrails.org/v7.0/classes/ActiveRecord/QueryMethods.html#method-i-offset)
