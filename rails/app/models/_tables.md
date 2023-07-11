# 管理用テーブル
#### `schema_migrations`
- マイグレーションの実行情報 (バージョン) を保存するテーブル
- マイグレーションが実行される際、`schema_migrations`テーブル内にレコードが存在しないバージョンに対応する
  マイグレーションファイルのみが実行される
- `schema_migrations`にレコードがあるが、それに対応するマイグレーションファイルがない場合、
  `$ rails db:migrate:status`は`********** NO FILE **********`を表示する

#### `ar_internal_metadata` (Rails 5.x~)
- マイグレーションやスキーマファイルのロード時 (`rake db:schema:load`など) に
  その処理を行った実行環境を保存するテーブル
- 処理を実行しようとするenvironmentと最後にマイグレーションなどを実施したenvironmentの整合性チェックを行い
  不用意なデータの消失を防ぐために使用される

#### `active_storage_blobs` (Rails 6.x~)
- ActiveStorage関連
- アップロードファイルの実体情報を保存するテーブル

#### `active_storage_attachments` (Rails 6.x~)
- ActiveStorage関連
- ActiveStorageを利用するモデルのテーブルと`active_storage_blobs`の中間テーブル
- ActiveStorageを利用するモデルのクラス名を保存する
