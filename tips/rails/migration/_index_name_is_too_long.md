# `ArgumentError: Index name 'index_users_on_xxxx' on table 'users' is too long`
- `name`オプションでエイリアスをつけて回避する
```ruby
add_index :users, %i[hoge fuga moge], unique: true, name: 'original_uniqueness_index'
```
