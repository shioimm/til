# コマンド
#### `$ rails db:migrate:redo`
- 一つ前のマイグレーションに戻してからもう一度マイグレーションを実行する
- up/downが両方とも可能かを確認するために使用する

#### `$ rails db:migrate:reset`
- DBをdropした後にcreateし、マイグレーションファイルを元にマイグレーションを実行する

##3# `$ rails db:reset` / `$ rails db:drop db:setup`
- DBをdropし後に現在のスキーマを読み込みcreateする
- マイグレーションを実行しない
