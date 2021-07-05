# 特定の条件のみユニーク制約をかけたい(PostgreSQL / SQLite)
- 部分インデックスを使用する
- `where`オプションで条件を指定する
```ruby
# enum status: { active: 0, inactive: 1 }
# statusがactiveなユーザーのみemailにユニーク制約をかけたい

add_index :users, %i[email status], unique: true, where: 'status = 0'
```
