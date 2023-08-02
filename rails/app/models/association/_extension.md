# ActiveRecord::Associations

```ruby
class Author < ApplicationRecord
  has_many :books do
    def latest
      order(created_at: :desc).first
    end
  end
end

Author.take.books.latest
```

```ruby
module LatestExtension
  def latest
    order(created_at: :desc).first
  end
end

class Author < ApplicationRecord
  has_many :books, -> { extending LatestExtension }
end

Author.take.books.latest
```
