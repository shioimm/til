# `:touch`
- オブジェクトのsave / destroy時、
  関連付けられたオブジェクトの`updated_at` / `updated_on`タイムスタンプを現在の時刻に更新する

```ruby
class Book < ApplicationRecord
  belongs_to :author, touch: true # Authorのタイムスタンプを更新
end

class Author < ApplicationRecord
  has_many :books
end
```
