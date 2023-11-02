# `No migration with version number`
- [railsのマイグレーションステータス'NO FILE'を削除する](https://qiita.com/yukofeb/items/ce39c7aabbfdc16205ea)
1. `rails db:migarte:status`で`********** NO FILE **********`が表示されているバージョン番号を確認
2. `touch db/migrate/バージョン番号_tmp.rb`
```ruby
# ActiveRecord::Migrationのバージョンを記述
class Tmp < ActiveRecord::Migration[6.0]
  def change
  end
end
```
3. `rails db:migrate:down VERSION=バージョン番号`
4. `rm db/migrate/バージョン番号_tmp.rb`
