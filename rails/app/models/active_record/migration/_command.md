# コマンド
## `$ rails g migration`

| 処理               | コマンド引数                           | ファイルに追加される内容 |
| -                  | -                                      | -                        |
| カラムの追加       | `add_<ColumnName>_to_<TableName>`      | `add_column`             |
| カラムの削除       | `remove_<ColumnName>_from_<TableName>` | `remove_column`          |
| テーブルの生成     | `create_<TableName>`                   | `create_table`           |
| joinテーブルの生成 | `create_join_table_<TableName>`        | `create_join_table`      |

## `$ rails db:migrate`
- まだ実行されていない`change`または`up`メソッドを実行 + `$ db:schema:dump` (スキーマファイルの更新) を実行

#### `$ rails db:migrate:redo`
- 一つ前のマイグレーションに戻してからもう一度マイグレーションを実行する
- up/downが両方とも可能かを確認するために使用する
- n以上前のマイグレーションから再実行する場合 `$ rails db:migrate:redo STEP=n`

#### `$ rails db:migrate:reset`
- DBをdropした後にcreateし、マイグレーションファイルを元にマイグレーションを実行する

### 利用できる環境変数
- `VERSION`
- `STEP`
- `RAILS_ENV`
- `VERBOSE`

## `$ rails db:reset`
- DBをdropし後に現在のスキーマを読み込みcreateする

## `$ rails db:schema:load`
- 現時点で存在しているスキーマファイルを元にテーブルを作成
- テーブルが既にある場合は削除、再作成
- `$ rails db:setup`は`$ rails db:create` + `$ rails db:schema:load` + `$ rails db:seed`
