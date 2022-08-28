# `change_column`

```ruby
def up
  change_column :users, :name, :string, limit: 30
end

def down
  change_column :users, :name, :string
end
```

- down時はup時と逆の処理を行わない
- down時の処理はup時のマイグレーションファイルに別途記載する必要がある
