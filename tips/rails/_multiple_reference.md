# 一つのモデルを複数のモデルのようにアソシエーションする
1. 一つのテーブルに対して複数のreferenceを貼る
```ruby
class CreateRelationships < ActiveRecord::Migration[6.0]
  def change
    create_table :relationships do |t|
      t.references :follower, foreign_key: { to_table: :users }
      t.references :followee, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
```

2. 各モデルにアソシエーションを追加
```ruby
class User < ApplicationModel
  has_many :following_relationships,
           inverse_of: :followee,
           class_name: 'Relationsip',
           foreign_key: 'followee_id',
           dependent: :destroy
  has_many :followed_relationships,
           inverse_of: :follower,
           class_name: 'Relationsip',
           foreign_key: 'follower_id',
           dependent: :destroy
end
```

```ruby
class Relationsip
  belongs_to :followee,
             inverse_of: :following_relationships,
             class_name: 'User',
             foreign_key: 'followee_id'
  belongs_to :follower,
             inverse_of: :followed_relationships
             class_name: 'User',
             foreign_key: 'follower_id'
end
```
