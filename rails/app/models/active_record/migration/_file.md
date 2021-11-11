# マイグレーションファイル
#### `add_column`

```ruby
def change
  add_column :users, :name, :string, limit: 30
end
```
- down時はup時と逆の処理を行う
- down時の処理はup時のマイグレーションファイルを元に自動生成される


#### `change_column`

```ruby
def up
  change_column :users, :name, :string, limit: 30
end

def down
  change_column :users, :name, :string
end
```

- down時はup時と逆の処理を行わない
- down時の処理はup時のマイグレーションファイルに別途記載する必要がある

#### `remove_column`

```ruby
  def change
    # rails db:rollbackできるように型を指定する
    # カラムオプションがある場合は指定しておく
    remove_column :user, :birthday, :datetime, null: false
  end
```

- カラムを削除する前にモデルに`self.ignored_columns = %w[]`を指定する変更をマージする
- カラムを削除する前にあらかじめデータをエクスポートしておく
  - Redashでデータをエクスポートする
  - Herokuでバックアップデータをダウンロードする

#### `drop_table`

```ruby
def change
  drop_table :users do |t|
    t.string :name, null: false

    t.timestamps
  end
end
```

- reversibleにしないとrollbackできない

#### `change_column_default`
- カラムのデフォルト値を変更する

```
change_column_default :books, :category, from: 0, to: 1
```

## timestampについて
```ruby
t.datetime :x_date, default: -> { 'NOW()' }
```

- `CURRENT_TIMESTAMP`を使用することができる
- アプリケーションと別にDBのタイムゾーンの設定が必要

```console
ALTER DATABASE "DB_NAME" SET timezone TO 'Asia/Tokyo';
```

## referencesについて
#### 外部キーと参照先のテーブル名が異なる場合

```ruby
# postsテーブルからusersテーブルを参照したいが、カラム名はwriter_idにしたい
add_reference :posts, :writer, foreign_key: { to_table: :users }
```

- [マイグレーションにおいて参照先テーブル名を自動で推定できないカラムを外部キーとして指定する方法](https://qiita.com/kymmt90/items/03cb9366ff87db69f539)

## `lock_version`について
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

## typeについて
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

## 参照
- [Active Record マイグレーション](https://railsguides.jp/active_record_migrations.html)
