# `lock_version`
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
