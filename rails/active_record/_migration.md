- 参照: [Active Record マイグレーション](https://railsguides.jp/active_record_migrations.html)

### remove_column
- カラムを削除する場合はあらかじめデータを引き抜く
  - 例: Redashでデータをエクスポートする
  - 例: Herokuでバックアップデータをダウンロードする

```ruby
  def change
    # rails db:rollbackできるように型を指定する
    # (カラムオプションがある場合はカラムオプションも指定)
    remove_column :user, :birthday, :datetime, null: false
  end
```

### drop_table
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

- CURRENT_TIMESTAMPを使用することができる
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
