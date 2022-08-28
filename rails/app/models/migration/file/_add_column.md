# `add_column`

```ruby
def change
  add_column :users, :name, :string, limit: 30
end
```

- down時はup時と逆の処理を行う
- down時の処理はup時のマイグレーションファイルを元に自動生成される
