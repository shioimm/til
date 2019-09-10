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
