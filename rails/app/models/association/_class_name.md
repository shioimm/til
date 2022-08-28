# `:class_name`
- 関連付け先のオブジェクト名を関連付け名から推論できない場合
  `:class_name`オプションを利用して関連先のモデル名を明示的に指定する

```ruby
module Publisher
  class Book < ApplicationRecord
    belongs_to :author, class_name: "User::Author"
  end
end

module User
  class Author < ApplicationRecord
    has_many :books, class_name: "Publisher::Book"
  end
end
```
