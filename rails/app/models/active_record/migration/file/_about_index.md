# index
- 新規作成するreference型のカラムにUNIQUE制約を付与したい場合

```ruby
create_table :profiles do |t|
  t.references :user, foreign_key: true, index: { unique: true }, null: false

  t.timestamps
end
```
