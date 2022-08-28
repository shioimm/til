# `drop_table`

```ruby
def change
  drop_table :users do |t|
    t.string :name, null: false

    t.timestamps
  end
end
```

- reversibleにしないとrollbackできない
