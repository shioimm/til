# マイグレーション
## マイグレーションファイル
- 参照: [Active Record マイグレーション](https://railsguides.jp/active_record_migrations.html)

### `add_column`
- 既存のテーブルに新しいカラムを追加する
- down時はup時と逆の処理を行う
  - down時のコードはup時のマイグレーションファイルを元に自動生成される
```ruby
def change
  add_column :users, :name, :string, limit: 30
end
```

### `change_column`
- 既存のカラムを変更する
- down時はup時と逆の処理を行わない
  - down時のコードはup時のマイグレーションファイルに別途記載する必要がある
```ruby
def up
  change_column :users, :name, :string, limit: 30
end

def down
  change_column :users, :name, :string
end
```

### `remove_column`
- カラムを削除する場合はあらかじめデータを引き抜く
  - 例: Redashでデータをエクスポートする
  - 例: Herokuでバックアップデータをダウンロードする

```ruby
  def change
    # rails db:rollbackできるように型を指定する
    # カラムオプションがある場合は
    # カラムオプションも指定しておかないとrollback時に元に戻らなくなる
    remove_column :user, :birthday, :datetime, null: false
  end
```

### `drop_table`
- テーブルを削除する際はreversibleにする

- 良い例
```ruby
def change
  drop_table :users do |t|
    t.string :name, null: false

    t.timestamps
  end
end
```

- 悪い例(rollbackできない)
```ruby
def change
  drop_table :users
end
```

### timestamp
```ruby
t.datetime :x_date, default: -> { 'NOW()' }
```

- `CURRENT_TIMESTAMP`を使用することができる
  - DBのタイムゾーンはアプリケーション側と別に設定が必要
```console
ALTER DATABASE "DB_NAME" SET timezone TO 'Asia/Tokyo';
```

### references
#### 外部キーと参照先のテーブル名が異なる場合
- `to_table`オプション
```ruby
# lessonsテーブルからusersテーブルを参照したいが、カラム名はteacher_idにしたい
# 新規テーブル作成時
create_table :lessons do |t|
  t.references :teacher, foreign_key: { to_table: :users }, null: false
end
```
```ruby
# 外部キーを後から追加する場合
add_reference :lessons :teacher, foreign_key: { to_table: :users }
```
- `column`オプション
```ruby
create_table :lessons do |t|
  t.references :teacher
end
add_foreign_key :lessons, :users, column: :teacher_id
```
- 参照: [マイグレーションにおいて参照先テーブル名を自動で推定できないカラムを外部キーとして指定する方法](https://qiita.com/kymmt90/items/03cb9366ff87db69f539)

### `lock_version`
- テーブルに`lock_version`カラムを追加すると、該当するモデルに楽観的ロックを追加できる
```ruby
add_column :books, :lock_version, :integer, default: 0, null: false
```
- `lock_version`はレコードのupdate時にカウントアップされる
  - フォームからパラメータとして送信する
- update時に`lock_version`が異なると競合が発生し、`ActiveRecord::StaleObjectError`が発生する
  - update時に`ActiveRecord::StaleObjectError`のエラーハンドリングを行う

#### フォーム側の実装
- `lock_version`を`hidden_field`に持たせる
```haml
= f.hidden_field :lock_version
```

#### 悲観的ロック
- `ActiveRecord::Base.transaction`の中で
  - レコード取得時に`ActiveRecord::Locking::Pessimistic#lock`を使用する
  - レコード更新前に`ActiveRecord::Locking::Pessimistic#lock!`を使用する
- `ActiveRecord::Locking::Pessimistic#with_lock`を使用する

### type
- テーブルにtypeカラム(string)を追加すると、該当するモデルをSTIにすることができる
- typeを実装したテーブルに該当するモデル = スーパークラス
- 該当モデルを継承したクラス = サブクラス
- レコード生成時、type属性にサブクラス名を指定する
```ruby
# Novelモデルのレコードを生成
Book.new(type: 'Novel')
# Bookモデルのレコードを生成
Book.new(type: '')
```
- enumを使用することもできる
```ruby
class Book < ApplicationRecord
  enum type: {
    Novel: 'Novel',
    Magazine: 'Magazine',
  }
```

## コマンド
### `$ rails db:migrate:redo`
- 一つ前のマイグレーションに戻してからもう一度マイグレーションを実行する
- up/downが両方とも可能かを確認するために使用する

### `$ rails db:migrate:reset`
- DBをdropした後にcreateし、マイグレーションファイルを元にマイグレーションを実行する

### `$ rails db:reset` / `$ rails db:drop db:setup`
- DBをdropし後に現在のスキーマを読み込みcreateする
- マイグレーションを実行しない

## 事例
### `No migration with version number`
- 参照: [railsのマイグレーションステータス'NO FILE'を削除する](https://qiita.com/yukofeb/items/ce39c7aabbfdc16205ea)
1. `rails db:migarte:status`で`********** NO FILE **********`が表示されているバージョン番号を確認
2. `touch db/migrate/バージョン番号_tmp.rb`
```ruby
class Tmp < ActiveRecord::Migration[6.0] # ActiveRecord::Migrationのバージョンを記述
  def change
  end
end
```
3. `rails db:migrate:down VERSION=バージョン番号`
4. `rm db/migrate/バージョン番号_tmp.rb`

### CONFLICT (content): Merge conflict in db/schema.rb
- masterブランチrebase時、scheme.rbがコンフリクト
- 参照: [コンフリクトしたschema.rbをきれいにマージする手順](https://qiita.com/jnchito/items/494a0499b808f109e0a8)
1. `$ git reset HEAD db/schema.rb`でschema.rbのステージングを解除
2. `$ git checkout db/schema.rb`でschema.rbの変更をリセット
3. `$ rails db:migrate`(マイグレーションファイルは追加されているためマイグレーション可能)
4. `$ git add db/schema.rb`
5. `$ git rebase --continue`

### `ArgumentError: Index name 'index_users_on_xxxx' on table 'users' is too long; the limit is 63 characters`
- `name`オプションでエイリアスをつけて回避する
```ruby
add_index :users, %i[hoge fuga moge], unique: true, name: 'original_uniqueness_index'
```

### 特定の条件のみユニーク制約をかけたい(PostgreSQL / SQLite)
- 部分インデックスを使用する
- `where`オプションで条件を指定する
```ruby
# enum status: { active: 0, inactive: 1 }
# statusがactiveなユーザーのみemailにユニーク制約をかけたい

add_index :users, %i[email status], unique: true, where: 'status = 0'
```
