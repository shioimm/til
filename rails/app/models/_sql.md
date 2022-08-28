# SQL
```ruby
id  = 1
sql = ActiveRecord::Base.sanitize_sql_array(['select name from users where id = :id', id: id])

ActiveRecord::Base.connection.select_all(sql).to_a # => [{"name"=>...}]
```

```ruby
# Select文を実行し、結果をActiveRecord::Resultで取得する
ActiveRecord::Base.connection.select_all(sql)

# SQLを実行し、結果をActiveRecordを継承したモデルのインスタンスの配列で取得する
MODEL.find_by_sql(sql)

# SQLを実行する
ActiveRecord::Base.connection.execute(sql)
```
