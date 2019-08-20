### drop_table

- テーブルを削除する際はreversibleにする

- 良い例
```ruby
def change
  drop_table :users do |t|
    t.string :name, null: false

    t.timestamps
  end
end
```

- 悪い例(rollbackできない)
```ruby
def change
  drop_table :users
end
```
