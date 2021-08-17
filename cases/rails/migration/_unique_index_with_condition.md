# 特定の条件のみユニーク制約をかけたい(PostgreSQL / SQLite)
- [`add_index`](https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_index)
- 部分インデックスを使用する
- `where`オプションで条件を指定する

```ruby
# deleted_atがnilのuserのみemailにユニーク制約をかけたい

add_index :users, :email, unique: true, where: 'deleted_at IS NULL'
```
