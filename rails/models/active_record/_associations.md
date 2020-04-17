# ActiveRecord::Associations
- 参照: [Active Record の関連付け](https://railsguides.jp/association_basics.html)

## `inverse_of`
- 参照: [inverse_of について](https://qiita.com/itp926/items/9cac175d3b35945b8f7e)
- ActiveRecordで双方向の関連付けをするとき、`inverse_of`オプションを使用することによって、
関連が同じオブジェクトを指していることを明示する
  - Rails4.1 以降はデフォルトで指定されている

### 使い所
- `foreign_key` `order`などのオプションを使用している場合
```ruby
class CustomerUser < User
  has_one :customer_information, foreign_key: :user_id, inverse_of: :user, dependent: :destroy
end
```

## `dependent`
- 参照: [dependent: :restrict_with_error と :restrict_with_exception の違い](https://qiita.com/jnchito/items/3456ce734ef41d216ecd)
- 子レコードごと消したい
  - `:destroy`
  - `:delete_all`
    - DBを直接操作し、コールバックを発生させない

- 子レコードはそのまま残し、外部キーをNULLにしたい
  - :nullify

- 子レコードが存在する親レコードの削除を引き止めたい
  - `:restrict_with_exception`
    - ActiveRecord::DeleteRestrictionErrorを発生させる
  - `:restrict_with_error`
    - 親レコードにエラーを追加する

## 事例
### 一つのモデルを複数のモデルのようにアソシエーションする
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
  has_many :following_relationships, class_name: 'Relationsip', foreign_key: 'followee_id', dependent: :destroy
  has_many :followed_relationships, class_name: 'Relationsip', foreign_key: 'follower_id', dependent: :destroy
end
```

```ruby
class Relationsip
  belongs_to :followee, class_name: 'User', foreign_key: 'followee_id'
  belongs_to :follower, class_name: 'User', foreign_key: 'follower_id'
end
```
