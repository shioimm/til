# 既に存在するインデックスに対して一意制約を追加したい
```
$ rails g migration change_users_email
```

```ruby
class ChangeUsersEmail < ActiveRecord::Migration[6.0]
  def change
    reversible do |dir|
      dir.up do
        remove_index :users :email
        add_index :users, :email, unique: true
      end

      dir.down do
        remove_index :users :email
        add_index :users, :email
      end
    end
  end
end
```

- reversibleにしないとrollback時にActiveRecord::IrreversibleMigrationが発生する
