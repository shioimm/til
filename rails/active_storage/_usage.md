## Usage
```
# ActiveStorage::Blob/ActiveStorage::Attachmentのマイグレーションファイルを生成
$ rails active_storage:install

$ rails g scaffold Foo avatar:attachment
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

```
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

## 参照
- Ruby on Rails 6エンジニア養成読本 押さえておきたい！Rails 6で改善された機能一覧
- パーフェクトRuby on Rails[増補改訂版] P225-234 / 384 / 386
