# `remove_column`

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
