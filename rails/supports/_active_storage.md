# ActiveStorage
- 参照: Ruby on Rails 6エンジニア養成読本 押さえておきたい！Rails 6で改善された機能一覧
- 参照: パーフェクトRuby on Rails[増補改訂版] P225-234 / 384 / 386

## TL;DR
- Railsが標準で提供する画像アップロード機能

### サポートしている画像変換用プロセッサ
- ImageMagick
- GraphicsMagick
- lipvips

### 関連モデル
#### `ActiveStorage::Blob`モデル
- アップロードファイルのメタ情報を扱う
- `ActiveStorage::Blob has_many Attachments`

#### `ActiveStorage::Attachment`モデル
- ActiveStorageを使用するXxxモデルとActiveStorage::Blobモデルの中間テーブル
- `Xxx has_many ActiveStorage::Attachments`

#### ActiveStorageを使用するXxxモデル
- ポリモーフィック関連によって画像を扱う
- `Xxx has_one_acctached :画像用カラム`
  - `Xxx has_many_acctached :画像用カラム`
- XxxとActiveStorage::Blobは一対一で関連づけられる
```ruby
class Xxx < ApplicationRecord
  has_one_attached :画像用カラム
  # has_many_acctached :画像用カラム でもOK
end
```
- `dependent: false` - 削除時、関連する`ActiveStorage::Attachment`のみ削除される
  1. `ActiveStorage::Attachment`削除
  2. `ActiveStorage::PurgeJob`(非同期処理)実行
  3. 非同期処理の中で`ActiveStorage::Blob`や画像を削除

## Usage
```
# ActiveStorage::Blob/ActiveStorage::Attachmentのマイグレーションファイルを生成
$ rails active_storage:install

$ rails g scaffold Xxx 画像用カラム:attachment
$ rails db:migrate
```

### ストレージの設定
```yml
# config/storage.yml
# デフォルトでS3、GCS、AzureStorageに対応
# ミラーリング用の設定はmirrorに記述する

test:
  service: Disk
  root: <%= Rails.root.join("tmp/storage") %>

local:
  service: Disk
  root: <%= Rails.root.join("storage") %>
```

- 環境ごとに設定に反映させる
```ruby
# config/environments/development.rb

config.active_storage.service = :local
```

### 画像のリサイズ
- 画像のリサイズは画像の存在するURLにアクセスした時点で処理される
  - リソースに対してBlobのidと変換形式を含んだURLが生成される
- ImageProccessing(gem)とImageMagic(brew)が必要
- リソースに対し`variant`メソッドを呼び出し、引数でサイズを指定
  - 指定できるサイズのオプションはImageProccessing::MiniMagic(or ImageMagic)に依存する
```haml
= @record.image.variant(resize_to_limit: [100, 100])
```
- variantは返り値としてBlobのidと変換形式を含んだURLを生成する
- URLはサーバー側で検証される
  - 変換後の画像がストレージに存在する場合は画像のURLにリダイレクトする
  - 変換後の画像がストレージに存在しない場合はストレージから画像をダウンロードして変換を行い、
    変換後の画像をアップロードして画像のURLにリダイレクトする
  - 改ざんが検知されると無効になる

### ダイレクトアップロード
- アプリケーションサーバーを経由せずファイルを直接クラウドストレージにアップロードする
```js
// app/javascript/appliction.js
// ダイレクトアップロード用のライブラリを読み込み
require ("@rails/activestorage").start()
```
```haml
= f.file_field :画像用カラム, direct_upload: true
```

## ActiveStorageの課題
- 公式のvalidationヘルパーがバンドルされていない
  - gem `active_storage_validation`などを使用する
- cacheの不足
  - バリデーションでフォームに戻った際、画像を添付し直す必要がある
