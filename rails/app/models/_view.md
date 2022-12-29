# VIEW
- scenic gemを利用

```ruby
$ rails generate scenic:view published_books
```

```ruby
class AddPublishedBooks < ActiveRecord::Migration
  create_view :published_books
end
```

```sql
-- 内容を記述する
-- db/views/published_books_v01.sql

select title
from books
where published_at is not null;
```

```ruby
# app/models/published_book.rb

class PublishedBook < ApplicationRecord
end

@published_books = PublishedBook.all
```

#### VIEWの更新

```ruby
class AddIsPublic < ActiveRecord::Migration
  def change
    add_column :books, :image, :string
    add_column :books, :is_public_image, :boolean, null: false, default: false

    # VIEW更新用の設定
    update_view :published_books, version: 2, revert_to_version: 1
  end
end
```

```sql
-- db/views/published_books_v02.sql

select title,
       case is_public_image
       when true then image
       else null
       end as image
from books
where published_at is not null;
```

## 参照
- [scenic-views/scenic](https://github.com/scenic-views/scenic)
- [RDBMSのVIEWを使ってRailsのデータアクセスをいい感じにする](https://techracho.bpsinc.jp/morimorihoge/2019_06_21/76521)
