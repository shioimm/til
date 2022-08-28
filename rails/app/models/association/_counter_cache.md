# `:counter_cache`
- 従属しているオブジェクト数をキャッシュする

```ruby
class Book < ApplicationRecord
  belongs_to :author, counter_cache: true
end

class Author < ApplicationRecord
  has_many :books # books_countカラムを追加する (自動的にattr_readonly: 読み出し専用になる)
end

# Author.first.books.size実行時にCOUNT(*)が実行されないように
# Book側にカウンタキャッシュを設定することにより
# キャッシュ値が最新の状態に保たれる
```

## 参照
- [`4.1.2.3 :counter_cache`](https://railsguides.jp/association_basics.html#belongs-to%E3%81%AE%E3%82%AA%E3%83%97%E3%82%B7%E3%83%A7%E3%83%B3-counter-cache)
