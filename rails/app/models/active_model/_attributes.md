# ActiveModel::Attributes
## ActiveModel::Attributes::BeforeTypeCast
#### `(属性名)_before_type_cast`
- DBへ保存される前 (型キャスト前) のデータ型を取得する

```ruby
class Todo < ActiveRecord::Base
end

todo = Todo.new(id: '1', completed_on: '2012-10-21')
todo.id           # => 1 (Integer)
todo.completed_on # => Sun, 21 Oct 2012 (Date)

todo.attributes_before_type_cast   # => {"id"=>"1", "completed_on"=>"2012-10-21", ... }
todo.id_before_type_cast           # => "1" (String)
todo.completed_on_before_type_cast # => "2012-10-21" (String)
```

### 参照
- [ActiveRecord::AttributeMethods::BeforeTypeCast](https://api.rubyonrails.org/classes/ActiveRecord/AttributeMethods/BeforeTypeCast.html)
- 現場で使える Ruby on Rails 5速習実践ガイドP426-427
