# SQL

```ruby
sql = ActiveRecord::Base.sanitize_sql(["title = ?", "The Pragmatic Programmer"])
Book.where(sql)
# => [#<Book ...

# Select文を実行
query = "select * from books where title = ?"
sql   = ActiveRecord::Base.sanitize_sql_array([query, "The Pragmatic Programmer"])

ActiveRecord::Base.connection.select_all(sql)
# => #<ActiveRecord::Result: ...

# SQL文を実行
query     = "update books set title = ? where title = ?"
title     = "The Pragmatic Programmer"
new_title = "The Pragmatic Programmer 2nd edition"
sql       = ActiveRecord::Base.sanitize_sql_array(query, title, new_title)

ActiveRecord::Base.connection.execute(sql)
# => #<PG::Result: ...
```
