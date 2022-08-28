# `change_column_null`
- カラムにNULL制約を追加する

```ruby
def change
  change_column_null    :books, :title, false
  change_column_default :books, :title, from: nil, to: "" # 後から追加する場合はデフォルト値が必要
end
```
