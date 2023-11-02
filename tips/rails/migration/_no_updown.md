# マイグレーション / ロールバック時にカラムを操作しない

```ruby
# (前提1) updated_atが不要なテーブルのupdated_atカラムを削除したい
# (前提2) updated_atはデフォルトでnull: falseであるため、ロールバックできない

class RemoveEventLogUpdatedAt < ActiveRecord::Migration[7.0]
  # #upを明示的に定義し、#downを明示的に書かないことによって
  # ロールバック時にカラム操作を行わないようにようにする

  def up
    remove_column :event_logs, :updated_at, :timestamp, null: false
  end
end
```

- `def down` を明示的に定義し、 `def up` を明示的に定義しなければ
  マイグレーション時に対象のテーブル・カラムは操作されない
- `def up` を明示的に定義し 、`def down` を明示的に書かなければ
  ロールバック時に対象のテーブル・カラムは操作されない
