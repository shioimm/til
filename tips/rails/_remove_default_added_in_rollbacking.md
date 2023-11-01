# ロールバック時に元のカラムになかった変更が追加されるようなマイグレーションファイルを実行してしまった

```ruby
class RemoveCategoryFromPosts < ActiveRecord::Migration[7.0]
  def up
    # 追加時の記述
    # add_column :posts, :category, :string, null: false
    remove_column :posts, :category
  end

  def down
    # 余計な default: '' が追加されている
    add_column :posts, :category, :string, null: false, default: ''
  end
end
```

- このマイグレーションファイルを実行した後ロールバックすると、
  元の`category`カラムにはなかった`default: ''`が追加されてしまう

#### 修正方法
- ロールバック済みの状態で`ALTER TABLE`する

```
ALTER TABLE posts ALTER COLUMN category DROP DEFAULT;
```

- マイグレーションファイルを修正

```ruby
class RemoveCategoryFromPosts < ActiveRecord::Migration[7.0]
  def up
    remove_column :posts, :category
  end

  def down
    # 余計な default: '' を削除
    add_column :posts, :category, :string, null: false
  end
end
```

- マイグレーションを実行 (空マイグレーションでもスキーマファイルは書き換わる)
