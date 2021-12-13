# virtual
#### generated column

```ruby
# SQL関数upper()の結果をDBに保存する (stored: true)

create_table :users do |t|
  t.string :name
  t.virtual :name_upcased, type: :string, as: 'upper(name)', stored: true
end
```

- [Add support for generated columns in PostgreSQL (Redux) by MSNexploder · Pull Request #41856 · rails/rails](https://github.com/rails/rails/pull/41856)
