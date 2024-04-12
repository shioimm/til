# SQL

```ruby
sql = ActiveRecord::Base.sanitize_sql(["title = ?", "The Pragmatic Programmer"])
Book.where(sql)
# => [#<Book ...
```

#### Select文を実行

```ruby
query = "select * from books where title = ?"
sql   = ActiveRecord::Base.sanitize_sql_array([query, "The Pragmatic Programmer"])

ActiveRecord::Base.connection.select_all(sql)
# => #<ActiveRecord::Result: ...
```

- `ActiveRecord::Base#select_all` -> `ActiveRecord::Result`を返す (`#to_a`、`#to_hash`を呼べる)
- `ActiveRecord::Base#select_one` -> 最初のレコードを表すHashオブジェクトを返す
- `ActiveRecord::Base#select_rows` -> 各行の各カラムの値を二次元配列で返す
- `ActiveRecord::Base#select_values` -> 最初のカラムの値を配列で返す
- `ActiveRecord::Base#select_value` -> 最初のレコードの最初のカラムの値を返す

```ruby
# e.g. メモリ上の値に対してPostGISの関数を呼ぶ

sql = <<~SQL
select
  st_asgeojson(
    st_transform(
      st_geomfromtext('POINT(***.*** **.***)', 4301)
      , 4326
    )
  )
SQL

ActiveRecord::Base.connection.select_one(sql)
=> {"st_asgeojson"=>"{\"type\":\"Point\",\"coordinates\":[***.***..., **.***...]}"}
```

#### SQL文を実行

- `ActiveRecord::Base.sanitize_sql` / `ActiveRecord::Base.sanitize_sql_for_conditions`
- `ActiveRecord::Base.sanitize_sql_array`

```ruby
sql = "role in (:roles)"
query = ActiveRecord::Base.sanitize_sql_for_conditions([sql, roles: [:admin, :seller]])
User.where(query)
```

```ruby
query     = "update books set title = ? where title = ?"
title     = "The Pragmatic Programmer"
new_title = "The Pragmatic Programmer 2nd edition"
sql       = ActiveRecord::Base.sanitize_sql_array(query, title, new_title)

ActiveRecord::Base.connection.execute(sql)
# => #<PG::Result: ...
```
