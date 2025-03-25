# `ActiveRecord::Batches#find_each` / `ActiveRecord::Batches#find_in_batches` / `ActiveRecord::Batches#in_batches`

`ActiveRecord::Batches#find_each`
- レコードをバッチ単位で処理 (デフォルトのバッチサイズは1000件)
- 内部的に`ActiveRecord::Batches#find_in_batches`を使用

```ruby
posts.find_each do |post|
  # ...
end
```

`ActiveRecord::Batches#find_in_batches`
- バッチ単位のレコードを配列として順にyield

```ruby
posts.find_in_batches do |posts_in_batch|
  # ....
end
```

`ActiveRecord::Batches#in_batches`
- バッチ単位のレコードをActiveRecord::Relationとして順にyield

```ruby
posts.in_batches do |posts_in_batch|
  # ....
end
```
