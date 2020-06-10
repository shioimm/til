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

### `has_one`: 新しいオブジェクトのbuildで古いオブジェクトがdestroyされる
```ruby
[1] pry(main)> current_use.build_profile(name: 'name').save
  User Load (0.5ms)  SELECT "users".* FROM "users" ORDER BY "users"."id" DESC LIMIT $1  [["LIMIT", 1]]
  Profile Load (0.5ms)  SELECT "profiles".* FROM "profiles" WHERE "profiles"."user_id" = $1 LIMIT $2  [["user_id", 42], ["LIMIT", 1]]
   (0.2ms)  BEGIN
  Profile Create (0.8ms)  INSERT INTO "profiles" ("name", "user_id", "created_at", "updated_at") VALUES ($1, $2, $3, $4) RETURNING "id"  [["name", "name"], ["user_id", 42], ["created_at", "2020-06-09 14:41:26.772362"], ["updated_at", "2020-06-09 14:41:26.772362"]]
   (0.6ms)  COMMIT
=> true
[2] pry(main)> current_user.build_profile(name: 'profile').save
  User Load (0.6ms)  SELECT "users".* FROM "users" ORDER BY "users"."id" DESC LIMIT $1  [["LIMIT", 1]]
  Profile Load (0.4ms)  SELECT "profiles".* FROM "profiles" WHERE "profiles"."user_id" = $1 LIMIT $2  [["user_id", 42], ["LIMIT", 1]]
   (0.3ms)  BEGIN
  Profile Destroy (0.5ms)  DELETE FROM "profiles" WHERE "profiles"."id" = $1  [["id", 21]]
   (0.4ms)  COMMIT
   (0.1ms)  BEGIN
  Profile Create (0.4ms)  INSERT INTO "profiles" ("name", "user_id", "created_at", "updated_at") VALUES ($1, $2, $3, $4) RETURNING "id"  [["name", "profile"], ["user_id", 42], ["created_at", "2020-06-09 14:41:38.683070"], ["updated_at", "2020-06-09 14:41:38.683070"]]
   (0.3ms)  COMMIT
=> true
```
- `build_association`を使用すると発生する
- 代わりに`new`や`find_or_initialize_by`を使用する

## 拡張
- 参照: [4.6関連付けの拡張](https://railsguides.jp/association_basics.html#%E9%96%A2%E9%80%A3%E4%BB%98%E3%81%91%E3%81%AE%E6%8B%A1%E5%BC%B5)
- 関連付けのプロキシオブジェクトをカスタマイズする
```ruby
class Book < ApplicationRecord
  has_many :chapters do
    def find_by_number_of_pages(number)
      find_by(number_of_pages: number)
    end
  end
end
```
- `Bookオブジェクト.chapters`で全てのchaptersを取得
- `Bookオブジェクト.chapters.find_by_number_of_pages(10)`で条件を満たすchaptersを取得

### 関連付けプロキシの内部参照
- `proxy_association.owner` -> Bookオブジェクトを返す
- `proxy_association.target` -> Bookオブジェクトに関連するchaptersのコレクションを返す
- `proxy_association.reflection` -> 関連付けを記述するリフレクションオブジェクトを返す
```ruby
pry(#<Chapter::ActiveRecord_Associations_CollectionProxy>)> proxy_association.reflection
=> #<ActiveRecord::Reflection::HasManyReflection:0x00007fd4d70e1290
 @active_record=Book(id: integer, title: string),
 @active_record_primary_key="id",
 @association_scope_cache=#<Concurrent::Map:0x00007fd4d70e1010 entries=0 default_proc=nil>,
 @class_name="Chapter",
 @constructable=true,
 @foreign_key="book_id",
 @foreign_type=nil,
 @inverse_name=nil,
 @klass=Chapter(id: integer, book_id: integer, number_of_pages: integer),
 @name=:chapters,
 @options={:extend=>[Book::ChaptersAssociationExtension], :autosave=>true},
 @plural_name="chapters",
 @scope=#<Proc:0x00007fd4d70e12e0@/xxxx/vendor/bundle/ruby/2.6.0/gems/activerecord-6.0.3/lib/active_record/associations/builder/association.rb:52>,
 @type=nil>
```
