# Active Storage
- 参照: Ruby on Rails 6エンジニア養成読本
- Railsが標準で提供する画像アップロード機能

```sh
$ rails active_storage:install
$ rails g scaffold Active Storageを利用するモデル 画像カラム:attachment
$ rails db:migrate
```
- インストールによって、AttachmentモデルとBlobモデルが生成される
  - 正確にはマイグレーションファイルが生成される
- Blob -> アップロードファイルのメタ情報を扱う
  - Blob has_many Attachments
- Attachment -> Active Storageを使用するモデルとBlobモデルの中間テーブル
  - Active Storageを使用するモデル has_many Attachmens
- Active Storageを使用するモデル -> ポリモーフィック関連によって画像を扱う
  - Active Storage has_one_acctached :画像カラム
    - -> Active Storageを利用するモデルとBlobを一対一で関連づける

### ファイルの保存場所
- ファイルの保存場所は`config/storage.yml`に記述し、環境ごとに設定に反映させる
```ruby
# config/environments/development.rb

config.active_storage.service = :development
```

### 画像のリサイズ
- 画像のリサイズは画像の存在するURLにアクセスした時点で処理される
  - リソースに対してBlobのidと変換形式を含んだURLが生成される
- ImageProccessing(gem)とImageMagic(brew)が必要
- リソースに対し`variant`メソッドを呼び出し、引数でサイズを指定
  - 指定できるサイズのオプションはImageProccessing(or ImageMagic)に依存する
```haml
= @record.image.variant(resize_to_limit: [100, 100])
```

