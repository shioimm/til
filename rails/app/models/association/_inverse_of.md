# `:inverse_of`
- ARは`:through`や`:foreign_key`オプションを使う双方向関連付けを自動認識しない
- `:inverse_of`オプションを使用することによって、
  双方の関連が同じオブジェクトを指していることを明示する

```ruby
class Author < ApplicationRecord
  has_many :books, inverse_of: 'writer' # 自クラスがWriterであることを明示
end

class Book < ApplicationRecord
  belongs_to :writer, class_name: 'Author', foreign_key: 'author_id'
end
```

## 参照
- [3.5 双方向関連付け](https://railsguides.jp/association_basics.html#%E5%8F%8C%E6%96%B9%E5%90%91%E9%96%A2%E9%80%A3%E4%BB%98%E3%81%91)
