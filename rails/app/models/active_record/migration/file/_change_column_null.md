# `change_column_null`
- カラムにNULL制約を追加する

```ruby
def change
  change_column_null :books, :title, false
end
```
